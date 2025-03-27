// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>


#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>


#define CMDBUF_SIZE	80	// enough for one VGA text line

uint32_t hexStoi(char *buf);

struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

// LAB 1: add your command to here...
static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display stack backtrace", mon_backtrace},
	{ "show", "Display 5 or more colors", mon_color},
	{"showmappings", "Display all of the physical page mappings", mon_showmappings},
	{"cmemp", "Display changed memory permission", mon_cmemp},
	{"memdump", "Display memory dump", mon_memdump},
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// LAB 1: Your code here.
    // HINT 1: use read_ebp().
    // HINT 2: print the current ebp on the first line (not current_ebp[0])

	cprintf("Stack backtrace:\n");

	int *ebp = (int *)read_ebp();
    
    while (ebp != 0){
        int eip = ebp[1];
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
        struct Eipdebuginfo info;
        if (debuginfo_eip(eip, &info) == 0) {
            cprintf("         %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
        }
        ebp = (int *)(*ebp);
    }
    return 0;
}

int
mon_color(int argc, char **argv, struct Trapframe *tf)
{
	// Print many colors
    cprintf("\33[0;33mCyan \33[0;35mGreen \33[0;36mPurple \33[0;31mBlue  \33[0;32mRed ");
	cprintf("\33[0;34mYellow \n");

	// Reset color
	cprintf("\33[0;0m"); 

  return 0;
}

int 
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
	// something wrong with user input
	if (argc <= 2){
		cprintf("Not proper user input. Need two address\n");
		return 0;
	}

	uint32_t start = hexStoi(argv[1]);
	uint32_t end = hexStoi(argv[2]);
	cprintf("start: 0x%x, end: 0x%x\n", start, end);
	//cprintf("PGSIZE: %d\n",PGSIZE);

	for (start ; start <= end; start += PGSIZE)
	{
		//cprintf("%x\n",start);
		pte_t *p_pte = pgdir_walk(kern_pgdir, (void *) start, 1);

		if (!p_pte) 
			panic("mon_showmappings: No p_pte");

		if (*p_pte & PTE_P)
		{
			cprintf("VADDR: %x, PHYSADDR: %08x  - ", start, PTE_ADDR(*p_pte));
			cprintf(" PTE_P: %x, PTE_W: %x, PTE_U: %x \n", *p_pte&PTE_P, (*p_pte&PTE_W), (*p_pte&PTE_U));
		}
		else
			cprintf("VADDR %x : not exist\n", start);
	}
	
	return 0;
}

int
mon_cmemp(int argc, char **argv, struct Trapframe *tf)
{
	//cprintf("not yet\n");
	if (argc <= 3){
		cprintf("\33[0;35mNot proper user input.\n");
		cprintf("\33[0;31mTip: \33[0;0mcmemp 0xAddr [1|0] [p|w|u]\n");
		return 0;
	}

	uint32_t addr = hexStoi(argv[1]);
	pte_t *p_pte = pgdir_walk(kern_pgdir, (void *) addr, 1);

	if (!p_pte) 
		panic("mon_cmemp: No p_pte");

	cprintf("\33[0;31m[Before] \33[0;0mVADDR: %x , PHYSADDR: %08x  - ", addr, PTE_ADDR(*p_pte));
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x \n", *p_pte&PTE_P, (*p_pte&PTE_W), (*p_pte&PTE_U));

	int i = 0;
	uint32_t perm = 0;

	// p-(112, 0x70), w-(119, 0x77), u-(117, 0x75)  
	while (argv[3][i])
	{

		if ((argv[3][i]=='p') | (argv[3][i]=='P')) perm = PTE_P;
		if ((argv[3][i]=='w') | (argv[3][i]=='W')) perm = PTE_W;
		if ((argv[3][i]=='u') | (argv[3][i]=='U')) perm = PTE_U;

		if (argv[2][0]=='0')
			*p_pte = *p_pte & ~perm;
		else
			*p_pte = *p_pte | perm;

		i++;
	}

	cprintf("\33[0;31m[After] \33[0;0mVADDR: %x , PHYSADDR: %08x  - ", addr, PTE_ADDR(*p_pte));
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x \n", *p_pte&PTE_P, (*p_pte&PTE_W), (*p_pte&PTE_U));

	return 0;
}
int 
mon_memdump(int argc, char **argv, struct Trapframe *tf)
{
	if (argc < 3)
	{
		cprintf("\33[0;35mNot proper user input.\n");
		cprintf("\33[0;31mTip: \33[0;0mmemdump 0xLowAddr 0xHighAddr \n");
		return 0;
	}

	uintptr_t lo = ROUNDDOWN(strtol(argv[1], NULL, 16), 16);
	uintptr_t hi = ROUNDDOWN(strtol(argv[2], NULL, 16), 16);

	for (uintptr_t i = lo; i <= hi; i += 16)
	{
		struct PageInfo *pp = page_lookup(kern_pgdir, (void *)i, NULL);	
		if (!pp)
		{
			cprintf("Not exist\n");
			continue;
		}
		else
		{
			cprintf("Vaddr: [%08x], Paddr: [%08x] - ", i, page2pa(pp)+PGOFF(i));
			for (int j = 0; j < 16; j += 4)
			{
				cprintf("%08lx ", *(long *)(i+j));
			}
			cprintf("\n");
			continue;
		}
			
	}

	return 0;
}

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}

		/***** helper functions *****/

uint32_t 
hexStoi(char *buf)
{
	uint32_t result = 0;

	// To skip "0x"
	buf += 2;

	while (*buf)
	{
		if ( (*buf >= 'a') & (*buf <= 'f')){
			// cprintf("Before *buf: %d\n", *buf);
			// cprintf("*buf - 'a': %d\n", *buf-'a');
			// cprintf("*buf - 'a' + '0': %d\n", *buf-'a'+'0');
			// cprintf("*buf - 'a' + '0'+10: %d\n", *buf-'a'+'0'+10);
			*buf = *buf-'a'+'0'+10;
			// cprintf("After *buf: %d\n", *buf);
		}
		
		// cprintf("result*16: %d\n", result*16);
		// cprintf("*buf-'0': %d\n", *buf-'0');
		result = result * 16 + *buf - '0';
		// cprintf("result: %d\n", result);
		buf++;
	}

	return result;
}

