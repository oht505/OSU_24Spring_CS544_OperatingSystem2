// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;
	extern volatile pte_t uvpt[];

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR))
		panic("pgfault: not writable\n");
	
	if (!(uvpt[ (uintptr_t)addr >> PTXSHIFT] & PTE_COW))
		panic("pgfault: not COW page\n");

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();

	if ((r = sys_page_alloc(envid, PFTEMP, (PTE_U|PTE_W))) < 0)
		panic("pgfault: sys_page_alloc() failed %e", r);

	//memcpy( (void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE );
	memcpy( (void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE );

	if ((r = sys_page_map(envid, (void *)PFTEMP, envid, (void *)ROUNDDOWN(addr, PGSIZE), (PTE_U|PTE_W))) < 0)
		panic("pgfault: sys_page_map() failed %e", r);
	
	if ((r = sys_page_unmap(envid, (void *)PFTEMP)) < 0)
		panic("pgfault: sys_page_unmap() failed %e", r);


	//panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	extern volatile pte_t uvpt[];
	envid_t p_envid = sys_getenvid();
	intptr_t va = (intptr_t)(pn * PGSIZE);

	// LAB 4: Your code here.
	if ( (uvpt[pn]) & (PTE_COW | PTE_W))
	{
		if ( (r = sys_page_map(p_envid , (void *)va, envid, (void *)va, (PTE_COW | PTE_U))) < 0 )
			panic("duppage: %e", r);

		if ( (r = sys_page_map(p_envid , (void *)va, p_envid, (void *)va,  (PTE_COW | PTE_U) )) < 0 )
			panic("duppage: %e", r);
	}
	else
	{
		if ( (r = sys_page_map(p_envid, (void *)va, envid, (void *)va, PTE_U)) < 0 )
			panic("duppage: %e", r);
	}

	//panic("duppage not implemented");
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	envid_t envid;
	uint8_t *addr;
	int r;

	set_pgfault_handler(pgfault);
	envid = sys_exofork();

	extern volatile pde_t uvpd[];
	extern volatile pte_t uvpt[];

	if (envid < 0)
		return envid;

	if (envid == 0)
	{
		envid = sys_getenvid();

		thisenv = &envs[ENVX(envid)];
		return 0;
	}
	
	for ( uintptr_t va = 0; va < UTOP; )
	{
		if ((uvpd[va >> PDXSHIFT] & PTE_P) == 0)
		{
			va += NPTENTRIES * PGSIZE;
			continue;
		}
		
		if ((uvpt[va >> PTXSHIFT] & PTE_P) == 0)
		{
			va += PGSIZE;
			continue;
		}
		
		if (va == (UXSTACKTOP - PGSIZE))
		{
			va += PGSIZE;
			continue;
		}

		if ((r = duppage(envid, (unsigned) (va/PGSIZE))) < 0)
			return r;

		va += PGSIZE;
	}

	if ( (r = sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), (PTE_U | PTE_W))) < 0)
		return r;

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		panic("fork: sys_env_set_status() failed %e", r);

	//panic("fork not implemented");
	return envid;
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
