
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6a 00 00 00       	call   f01000a8 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 1e 23 f0 00 	cmpl   $0x0,0xf0231e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 1e 23 f0    	mov    %esi,0xf0231e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 a5 6b 00 00       	call   f0106c09 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 e0 72 10 f0 	movl   $0xf01072e0,(%esp)
f010007d:	e8 ce 42 00 00       	call   f0104350 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 8f 42 00 00       	call   f010431d <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 30 76 10 f0 	movl   $0xf0107630,(%esp)
f0100095:	e8 b6 42 00 00       	call   f0104350 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 f8 09 00 00       	call   f0100a9e <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
	cons_init();
f01000af:	e8 bb 05 00 00       	call   f010066f <cons_init>
	cprintf("444544 decimal is %o octal!\n", 444544);
f01000b4:	c7 44 24 04 80 c8 06 	movl   $0x6c880,0x4(%esp)
f01000bb:	00 
f01000bc:	c7 04 24 4c 73 10 f0 	movl   $0xf010734c,(%esp)
f01000c3:	e8 88 42 00 00       	call   f0104350 <cprintf>
	mem_init();
f01000c8:	e8 22 18 00 00       	call   f01018ef <mem_init>
	env_init();
f01000cd:	e8 5c 3a 00 00       	call   f0103b2e <env_init>
	trap_init();
f01000d2:	e8 78 43 00 00       	call   f010444f <trap_init>
	mp_init();
f01000d7:	e8 1e 68 00 00       	call   f01068fa <mp_init>
	lapic_init();
f01000dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01000e0:	e8 3f 6b 00 00       	call   f0106c24 <lapic_init>
	pic_init();
f01000e5:	e8 96 41 00 00       	call   f0104280 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ea:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01000f1:	e8 91 6d 00 00       	call   f0106e87 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f6:	83 3d 88 1e 23 f0 07 	cmpl   $0x7,0xf0231e88
f01000fd:	77 24                	ja     f0100123 <i386_init+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ff:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100106:	00 
f0100107:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f010010e:	f0 
f010010f:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0100116:	00 
f0100117:	c7 04 24 69 73 10 f0 	movl   $0xf0107369,(%esp)
f010011e:	e8 1d ff ff ff       	call   f0100040 <_panic>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100123:	b8 32 68 10 f0       	mov    $0xf0106832,%eax
f0100128:	2d b8 67 10 f0       	sub    $0xf01067b8,%eax
f010012d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100131:	c7 44 24 04 b8 67 10 	movl   $0xf01067b8,0x4(%esp)
f0100138:	f0 
f0100139:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100140:	e8 bf 64 00 00       	call   f0106604 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100145:	bb 20 20 23 f0       	mov    $0xf0232020,%ebx
f010014a:	eb 4d                	jmp    f0100199 <i386_init+0xf1>
		if (c == cpus + cpunum())  // We've started already.
f010014c:	e8 b8 6a 00 00       	call   f0106c09 <cpunum>
f0100151:	6b c0 74             	imul   $0x74,%eax,%eax
f0100154:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0100159:	39 c3                	cmp    %eax,%ebx
f010015b:	74 39                	je     f0100196 <i386_init+0xee>
f010015d:	89 d8                	mov    %ebx,%eax
f010015f:	2d 20 20 23 f0       	sub    $0xf0232020,%eax
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100164:	c1 f8 02             	sar    $0x2,%eax
f0100167:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010016d:	c1 e0 0f             	shl    $0xf,%eax
f0100170:	8d 80 00 b0 23 f0    	lea    -0xfdc5000(%eax),%eax
f0100176:	a3 84 1e 23 f0       	mov    %eax,0xf0231e84
		lapic_startap(c->cpu_id, PADDR(code));
f010017b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100182:	00 
f0100183:	0f b6 03             	movzbl (%ebx),%eax
f0100186:	89 04 24             	mov    %eax,(%esp)
f0100189:	e8 e6 6b 00 00       	call   f0106d74 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f010018e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100191:	83 f8 01             	cmp    $0x1,%eax
f0100194:	75 f8                	jne    f010018e <i386_init+0xe6>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100196:	83 c3 74             	add    $0x74,%ebx
f0100199:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f01001a0:	05 20 20 23 f0       	add    $0xf0232020,%eax
f01001a5:	39 c3                	cmp    %eax,%ebx
f01001a7:	72 a3                	jb     f010014c <i386_init+0xa4>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001b0:	00 
f01001b1:	c7 04 24 94 79 1e f0 	movl   $0xf01e7994,(%esp)
f01001b8:	e8 7a 3b 00 00       	call   f0103d37 <env_create>
	sched_yield();
f01001bd:	e8 a0 50 00 00       	call   f0105262 <sched_yield>

f01001c2 <mp_main>:
{
f01001c2:	55                   	push   %ebp
f01001c3:	89 e5                	mov    %esp,%ebp
f01001c5:	83 ec 18             	sub    $0x18,%esp
	lcr3(PADDR(kern_pgdir));
f01001c8:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d2:	77 20                	ja     f01001f4 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001d8:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f01001df:	f0 
f01001e0:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f01001e7:	00 
f01001e8:	c7 04 24 69 73 10 f0 	movl   $0xf0107369,(%esp)
f01001ef:	e8 4c fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01001f4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001f9:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001fc:	e8 08 6a 00 00       	call   f0106c09 <cpunum>
f0100201:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100205:	c7 04 24 75 73 10 f0 	movl   $0xf0107375,(%esp)
f010020c:	e8 3f 41 00 00       	call   f0104350 <cprintf>
	lapic_init();
f0100211:	e8 0e 6a 00 00       	call   f0106c24 <lapic_init>
	env_init_percpu();
f0100216:	e8 e9 38 00 00       	call   f0103b04 <env_init_percpu>
	trap_init_percpu();
f010021b:	90                   	nop
f010021c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100220:	e8 4b 41 00 00       	call   f0104370 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100225:	e8 df 69 00 00       	call   f0106c09 <cpunum>
f010022a:	6b d0 74             	imul   $0x74,%eax,%edx
f010022d:	81 c2 20 20 23 f0    	add    $0xf0232020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100233:	b8 01 00 00 00       	mov    $0x1,%eax
f0100238:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010023c:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0100243:	e8 3f 6c 00 00       	call   f0106e87 <spin_lock>
	sched_yield();
f0100248:	e8 15 50 00 00       	call   f0105262 <sched_yield>

f010024d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010024d:	55                   	push   %ebp
f010024e:	89 e5                	mov    %esp,%ebp
f0100250:	53                   	push   %ebx
f0100251:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100254:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100257:	8b 45 0c             	mov    0xc(%ebp),%eax
f010025a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010025e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100261:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100265:	c7 04 24 8b 73 10 f0 	movl   $0xf010738b,(%esp)
f010026c:	e8 df 40 00 00       	call   f0104350 <cprintf>
	vcprintf(fmt, ap);
f0100271:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100275:	8b 45 10             	mov    0x10(%ebp),%eax
f0100278:	89 04 24             	mov    %eax,(%esp)
f010027b:	e8 9d 40 00 00       	call   f010431d <vcprintf>
	cprintf("\n");
f0100280:	c7 04 24 30 76 10 f0 	movl   $0xf0107630,(%esp)
f0100287:	e8 c4 40 00 00       	call   f0104350 <cprintf>
	va_end(ap);
}
f010028c:	83 c4 14             	add    $0x14,%esp
f010028f:	5b                   	pop    %ebx
f0100290:	5d                   	pop    %ebp
f0100291:	c3                   	ret    
f0100292:	66 90                	xchg   %ax,%ax
f0100294:	66 90                	xchg   %ax,%ax
f0100296:	66 90                	xchg   %ax,%ax
f0100298:	66 90                	xchg   %ax,%ax
f010029a:	66 90                	xchg   %ax,%ax
f010029c:	66 90                	xchg   %ax,%ax
f010029e:	66 90                	xchg   %ax,%ax

f01002a0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002a0:	55                   	push   %ebp
f01002a1:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002a8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002a9:	a8 01                	test   $0x1,%al
f01002ab:	74 08                	je     f01002b5 <serial_proc_data+0x15>
f01002ad:	b2 f8                	mov    $0xf8,%dl
f01002af:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002b0:	0f b6 c0             	movzbl %al,%eax
f01002b3:	eb 05                	jmp    f01002ba <serial_proc_data+0x1a>
		return -1;
f01002b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01002ba:	5d                   	pop    %ebp
f01002bb:	c3                   	ret    

f01002bc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002bc:	55                   	push   %ebp
f01002bd:	89 e5                	mov    %esp,%ebp
f01002bf:	53                   	push   %ebx
f01002c0:	83 ec 04             	sub    $0x4,%esp
f01002c3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002c5:	eb 2a                	jmp    f01002f1 <cons_intr+0x35>
		if (c == 0)
f01002c7:	85 d2                	test   %edx,%edx
f01002c9:	74 26                	je     f01002f1 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002cb:	a1 24 12 23 f0       	mov    0xf0231224,%eax
f01002d0:	8d 48 01             	lea    0x1(%eax),%ecx
f01002d3:	89 0d 24 12 23 f0    	mov    %ecx,0xf0231224
f01002d9:	88 90 20 10 23 f0    	mov    %dl,-0xfdcefe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002df:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01002e5:	75 0a                	jne    f01002f1 <cons_intr+0x35>
			cons.wpos = 0;
f01002e7:	c7 05 24 12 23 f0 00 	movl   $0x0,0xf0231224
f01002ee:	00 00 00 
	while ((c = (*proc)()) != -1) {
f01002f1:	ff d3                	call   *%ebx
f01002f3:	89 c2                	mov    %eax,%edx
f01002f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002f8:	75 cd                	jne    f01002c7 <cons_intr+0xb>
	}
}
f01002fa:	83 c4 04             	add    $0x4,%esp
f01002fd:	5b                   	pop    %ebx
f01002fe:	5d                   	pop    %ebp
f01002ff:	c3                   	ret    

f0100300 <kbd_proc_data>:
f0100300:	ba 64 00 00 00       	mov    $0x64,%edx
f0100305:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100306:	a8 01                	test   $0x1,%al
f0100308:	0f 84 f7 00 00 00    	je     f0100405 <kbd_proc_data+0x105>
	if (stat & KBS_TERR)
f010030e:	a8 20                	test   $0x20,%al
f0100310:	0f 85 f5 00 00 00    	jne    f010040b <kbd_proc_data+0x10b>
f0100316:	b2 60                	mov    $0x60,%dl
f0100318:	ec                   	in     (%dx),%al
f0100319:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010031b:	3c e0                	cmp    $0xe0,%al
f010031d:	75 0d                	jne    f010032c <kbd_proc_data+0x2c>
		shift |= E0ESC;
f010031f:	83 0d 00 10 23 f0 40 	orl    $0x40,0xf0231000
		return 0;
f0100326:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010032b:	c3                   	ret    
{
f010032c:	55                   	push   %ebp
f010032d:	89 e5                	mov    %esp,%ebp
f010032f:	53                   	push   %ebx
f0100330:	83 ec 14             	sub    $0x14,%esp
	} else if (data & 0x80) {
f0100333:	84 c0                	test   %al,%al
f0100335:	79 37                	jns    f010036e <kbd_proc_data+0x6e>
		data = (shift & E0ESC ? data : data & 0x7F);
f0100337:	8b 0d 00 10 23 f0    	mov    0xf0231000,%ecx
f010033d:	89 cb                	mov    %ecx,%ebx
f010033f:	83 e3 40             	and    $0x40,%ebx
f0100342:	83 e0 7f             	and    $0x7f,%eax
f0100345:	85 db                	test   %ebx,%ebx
f0100347:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010034a:	0f b6 d2             	movzbl %dl,%edx
f010034d:	0f b6 82 00 75 10 f0 	movzbl -0xfef8b00(%edx),%eax
f0100354:	83 c8 40             	or     $0x40,%eax
f0100357:	0f b6 c0             	movzbl %al,%eax
f010035a:	f7 d0                	not    %eax
f010035c:	21 c1                	and    %eax,%ecx
f010035e:	89 0d 00 10 23 f0    	mov    %ecx,0xf0231000
		return 0;
f0100364:	b8 00 00 00 00       	mov    $0x0,%eax
f0100369:	e9 a3 00 00 00       	jmp    f0100411 <kbd_proc_data+0x111>
	} else if (shift & E0ESC) {
f010036e:	8b 0d 00 10 23 f0    	mov    0xf0231000,%ecx
f0100374:	f6 c1 40             	test   $0x40,%cl
f0100377:	74 0e                	je     f0100387 <kbd_proc_data+0x87>
		data |= 0x80;
f0100379:	83 c8 80             	or     $0xffffff80,%eax
f010037c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010037e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100381:	89 0d 00 10 23 f0    	mov    %ecx,0xf0231000
	shift |= shiftcode[data];
f0100387:	0f b6 d2             	movzbl %dl,%edx
f010038a:	0f b6 82 00 75 10 f0 	movzbl -0xfef8b00(%edx),%eax
f0100391:	0b 05 00 10 23 f0    	or     0xf0231000,%eax
	shift ^= togglecode[data];
f0100397:	0f b6 8a 00 74 10 f0 	movzbl -0xfef8c00(%edx),%ecx
f010039e:	31 c8                	xor    %ecx,%eax
f01003a0:	a3 00 10 23 f0       	mov    %eax,0xf0231000
	c = charcode[shift & (CTL | SHIFT)][data];
f01003a5:	89 c1                	mov    %eax,%ecx
f01003a7:	83 e1 03             	and    $0x3,%ecx
f01003aa:	8b 0c 8d e0 73 10 f0 	mov    -0xfef8c20(,%ecx,4),%ecx
f01003b1:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003b5:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003b8:	a8 08                	test   $0x8,%al
f01003ba:	74 1b                	je     f01003d7 <kbd_proc_data+0xd7>
		if ('a' <= c && c <= 'z')
f01003bc:	89 da                	mov    %ebx,%edx
f01003be:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003c1:	83 f9 19             	cmp    $0x19,%ecx
f01003c4:	77 05                	ja     f01003cb <kbd_proc_data+0xcb>
			c += 'A' - 'a';
f01003c6:	83 eb 20             	sub    $0x20,%ebx
f01003c9:	eb 0c                	jmp    f01003d7 <kbd_proc_data+0xd7>
		else if ('A' <= c && c <= 'Z')
f01003cb:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ce:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003d1:	83 fa 19             	cmp    $0x19,%edx
f01003d4:	0f 46 d9             	cmovbe %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003d7:	f7 d0                	not    %eax
f01003d9:	89 c2                	mov    %eax,%edx
	return c;
f01003db:	89 d8                	mov    %ebx,%eax
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003dd:	f6 c2 06             	test   $0x6,%dl
f01003e0:	75 2f                	jne    f0100411 <kbd_proc_data+0x111>
f01003e2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003e8:	75 27                	jne    f0100411 <kbd_proc_data+0x111>
		cprintf("Rebooting!\n");
f01003ea:	c7 04 24 a5 73 10 f0 	movl   $0xf01073a5,(%esp)
f01003f1:	e8 5a 3f 00 00       	call   f0104350 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003fb:	b8 03 00 00 00       	mov    $0x3,%eax
f0100400:	ee                   	out    %al,(%dx)
	return c;
f0100401:	89 d8                	mov    %ebx,%eax
f0100403:	eb 0c                	jmp    f0100411 <kbd_proc_data+0x111>
		return -1;
f0100405:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010040a:	c3                   	ret    
		return -1;
f010040b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100410:	c3                   	ret    
}
f0100411:	83 c4 14             	add    $0x14,%esp
f0100414:	5b                   	pop    %ebx
f0100415:	5d                   	pop    %ebp
f0100416:	c3                   	ret    

f0100417 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100417:	55                   	push   %ebp
f0100418:	89 e5                	mov    %esp,%ebp
f010041a:	57                   	push   %edi
f010041b:	56                   	push   %esi
f010041c:	53                   	push   %ebx
f010041d:	83 ec 1c             	sub    $0x1c,%esp
f0100420:	89 c7                	mov    %eax,%edi
f0100422:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100427:	be fd 03 00 00       	mov    $0x3fd,%esi
f010042c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100431:	eb 06                	jmp    f0100439 <cons_putc+0x22>
f0100433:	89 ca                	mov    %ecx,%edx
f0100435:	ec                   	in     (%dx),%al
f0100436:	ec                   	in     (%dx),%al
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	89 f2                	mov    %esi,%edx
f010043b:	ec                   	in     (%dx),%al
	for (i = 0;
f010043c:	a8 20                	test   $0x20,%al
f010043e:	75 05                	jne    f0100445 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100440:	83 eb 01             	sub    $0x1,%ebx
f0100443:	75 ee                	jne    f0100433 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100445:	89 f8                	mov    %edi,%eax
f0100447:	0f b6 c0             	movzbl %al,%eax
f010044a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100452:	ee                   	out    %al,(%dx)
f0100453:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100458:	be 79 03 00 00       	mov    $0x379,%esi
f010045d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100462:	eb 06                	jmp    f010046a <cons_putc+0x53>
f0100464:	89 ca                	mov    %ecx,%edx
f0100466:	ec                   	in     (%dx),%al
f0100467:	ec                   	in     (%dx),%al
f0100468:	ec                   	in     (%dx),%al
f0100469:	ec                   	in     (%dx),%al
f010046a:	89 f2                	mov    %esi,%edx
f010046c:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010046d:	84 c0                	test   %al,%al
f010046f:	78 05                	js     f0100476 <cons_putc+0x5f>
f0100471:	83 eb 01             	sub    $0x1,%ebx
f0100474:	75 ee                	jne    f0100464 <cons_putc+0x4d>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100476:	ba 78 03 00 00       	mov    $0x378,%edx
f010047b:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f010047f:	ee                   	out    %al,(%dx)
f0100480:	b2 7a                	mov    $0x7a,%dl
f0100482:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100487:	ee                   	out    %al,(%dx)
f0100488:	b8 08 00 00 00       	mov    $0x8,%eax
f010048d:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f010048e:	89 fa                	mov    %edi,%edx
f0100490:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100496:	89 f8                	mov    %edi,%eax
f0100498:	80 cc 07             	or     $0x7,%ah
f010049b:	85 d2                	test   %edx,%edx
f010049d:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f01004a0:	89 f8                	mov    %edi,%eax
f01004a2:	0f b6 c0             	movzbl %al,%eax
f01004a5:	83 f8 09             	cmp    $0x9,%eax
f01004a8:	74 78                	je     f0100522 <cons_putc+0x10b>
f01004aa:	83 f8 09             	cmp    $0x9,%eax
f01004ad:	7f 0a                	jg     f01004b9 <cons_putc+0xa2>
f01004af:	83 f8 08             	cmp    $0x8,%eax
f01004b2:	74 18                	je     f01004cc <cons_putc+0xb5>
f01004b4:	e9 9d 00 00 00       	jmp    f0100556 <cons_putc+0x13f>
f01004b9:	83 f8 0a             	cmp    $0xa,%eax
f01004bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01004c0:	74 3a                	je     f01004fc <cons_putc+0xe5>
f01004c2:	83 f8 0d             	cmp    $0xd,%eax
f01004c5:	74 3d                	je     f0100504 <cons_putc+0xed>
f01004c7:	e9 8a 00 00 00       	jmp    f0100556 <cons_putc+0x13f>
		if (crt_pos > 0) {
f01004cc:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f01004d3:	66 85 c0             	test   %ax,%ax
f01004d6:	0f 84 e5 00 00 00    	je     f01005c1 <cons_putc+0x1aa>
			crt_pos--;
f01004dc:	83 e8 01             	sub    $0x1,%eax
f01004df:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e5:	0f b7 c0             	movzwl %ax,%eax
f01004e8:	66 81 e7 00 ff       	and    $0xff00,%di
f01004ed:	83 cf 20             	or     $0x20,%edi
f01004f0:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f01004f6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004fa:	eb 78                	jmp    f0100574 <cons_putc+0x15d>
		crt_pos += CRT_COLS;
f01004fc:	66 83 05 28 12 23 f0 	addw   $0x50,0xf0231228
f0100503:	50 
		crt_pos -= (crt_pos % CRT_COLS);
f0100504:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f010050b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100511:	c1 e8 16             	shr    $0x16,%eax
f0100514:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100517:	c1 e0 04             	shl    $0x4,%eax
f010051a:	66 a3 28 12 23 f0    	mov    %ax,0xf0231228
f0100520:	eb 52                	jmp    f0100574 <cons_putc+0x15d>
		cons_putc(' ');
f0100522:	b8 20 00 00 00       	mov    $0x20,%eax
f0100527:	e8 eb fe ff ff       	call   f0100417 <cons_putc>
		cons_putc(' ');
f010052c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100531:	e8 e1 fe ff ff       	call   f0100417 <cons_putc>
		cons_putc(' ');
f0100536:	b8 20 00 00 00       	mov    $0x20,%eax
f010053b:	e8 d7 fe ff ff       	call   f0100417 <cons_putc>
		cons_putc(' ');
f0100540:	b8 20 00 00 00       	mov    $0x20,%eax
f0100545:	e8 cd fe ff ff       	call   f0100417 <cons_putc>
		cons_putc(' ');
f010054a:	b8 20 00 00 00       	mov    $0x20,%eax
f010054f:	e8 c3 fe ff ff       	call   f0100417 <cons_putc>
f0100554:	eb 1e                	jmp    f0100574 <cons_putc+0x15d>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100556:	0f b7 05 28 12 23 f0 	movzwl 0xf0231228,%eax
f010055d:	8d 50 01             	lea    0x1(%eax),%edx
f0100560:	66 89 15 28 12 23 f0 	mov    %dx,0xf0231228
f0100567:	0f b7 c0             	movzwl %ax,%eax
f010056a:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
f0100570:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
	if (crt_pos >= CRT_SIZE) {
f0100574:	66 81 3d 28 12 23 f0 	cmpw   $0x7cf,0xf0231228
f010057b:	cf 07 
f010057d:	76 42                	jbe    f01005c1 <cons_putc+0x1aa>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010057f:	a1 2c 12 23 f0       	mov    0xf023122c,%eax
f0100584:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010058b:	00 
f010058c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100592:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100596:	89 04 24             	mov    %eax,(%esp)
f0100599:	e8 66 60 00 00       	call   f0106604 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010059e:	8b 15 2c 12 23 f0    	mov    0xf023122c,%edx
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005a9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005af:	83 c0 01             	add    $0x1,%eax
f01005b2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005b7:	75 f0                	jne    f01005a9 <cons_putc+0x192>
		crt_pos -= CRT_COLS;
f01005b9:	66 83 2d 28 12 23 f0 	subw   $0x50,0xf0231228
f01005c0:	50 
	outb(addr_6845, 14);
f01005c1:	8b 0d 30 12 23 f0    	mov    0xf0231230,%ecx
f01005c7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005cc:	89 ca                	mov    %ecx,%edx
f01005ce:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005cf:	0f b7 1d 28 12 23 f0 	movzwl 0xf0231228,%ebx
f01005d6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005d9:	89 d8                	mov    %ebx,%eax
f01005db:	66 c1 e8 08          	shr    $0x8,%ax
f01005df:	89 f2                	mov    %esi,%edx
f01005e1:	ee                   	out    %al,(%dx)
f01005e2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005e7:	89 ca                	mov    %ecx,%edx
f01005e9:	ee                   	out    %al,(%dx)
f01005ea:	89 d8                	mov    %ebx,%eax
f01005ec:	89 f2                	mov    %esi,%edx
f01005ee:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005ef:	83 c4 1c             	add    $0x1c,%esp
f01005f2:	5b                   	pop    %ebx
f01005f3:	5e                   	pop    %esi
f01005f4:	5f                   	pop    %edi
f01005f5:	5d                   	pop    %ebp
f01005f6:	c3                   	ret    

f01005f7 <serial_intr>:
	if (serial_exists)
f01005f7:	80 3d 34 12 23 f0 00 	cmpb   $0x0,0xf0231234
f01005fe:	74 11                	je     f0100611 <serial_intr+0x1a>
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100606:	b8 a0 02 10 f0       	mov    $0xf01002a0,%eax
f010060b:	e8 ac fc ff ff       	call   f01002bc <cons_intr>
}
f0100610:	c9                   	leave  
f0100611:	f3 c3                	repz ret 

f0100613 <kbd_intr>:
{
f0100613:	55                   	push   %ebp
f0100614:	89 e5                	mov    %esp,%ebp
f0100616:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100619:	b8 00 03 10 f0       	mov    $0xf0100300,%eax
f010061e:	e8 99 fc ff ff       	call   f01002bc <cons_intr>
}
f0100623:	c9                   	leave  
f0100624:	c3                   	ret    

f0100625 <cons_getc>:
{
f0100625:	55                   	push   %ebp
f0100626:	89 e5                	mov    %esp,%ebp
f0100628:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010062b:	e8 c7 ff ff ff       	call   f01005f7 <serial_intr>
	kbd_intr();
f0100630:	e8 de ff ff ff       	call   f0100613 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100635:	a1 20 12 23 f0       	mov    0xf0231220,%eax
f010063a:	3b 05 24 12 23 f0    	cmp    0xf0231224,%eax
f0100640:	74 26                	je     f0100668 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100642:	8d 50 01             	lea    0x1(%eax),%edx
f0100645:	89 15 20 12 23 f0    	mov    %edx,0xf0231220
f010064b:	0f b6 88 20 10 23 f0 	movzbl -0xfdcefe0(%eax),%ecx
		return c;
f0100652:	89 c8                	mov    %ecx,%eax
		if (cons.rpos == CONSBUFSIZE)
f0100654:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010065a:	75 11                	jne    f010066d <cons_getc+0x48>
			cons.rpos = 0;
f010065c:	c7 05 20 12 23 f0 00 	movl   $0x0,0xf0231220
f0100663:	00 00 00 
f0100666:	eb 05                	jmp    f010066d <cons_getc+0x48>
	return 0;
f0100668:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010066d:	c9                   	leave  
f010066e:	c3                   	ret    

f010066f <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010066f:	55                   	push   %ebp
f0100670:	89 e5                	mov    %esp,%ebp
f0100672:	57                   	push   %edi
f0100673:	56                   	push   %esi
f0100674:	53                   	push   %ebx
f0100675:	83 ec 1c             	sub    $0x1c,%esp
	was = *cp;
f0100678:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010067f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100686:	5a a5 
	if (*cp != 0xA55A) {
f0100688:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010068f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100693:	74 11                	je     f01006a6 <cons_init+0x37>
		addr_6845 = MONO_BASE;
f0100695:	c7 05 30 12 23 f0 b4 	movl   $0x3b4,0xf0231230
f010069c:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010069f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006a4:	eb 16                	jmp    f01006bc <cons_init+0x4d>
		*cp = was;
f01006a6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006ad:	c7 05 30 12 23 f0 d4 	movl   $0x3d4,0xf0231230
f01006b4:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
	outb(addr_6845, 14);
f01006bc:	8b 0d 30 12 23 f0    	mov    0xf0231230,%ecx
f01006c2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006c7:	89 ca                	mov    %ecx,%edx
f01006c9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ca:	8d 59 01             	lea    0x1(%ecx),%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cd:	89 da                	mov    %ebx,%edx
f01006cf:	ec                   	in     (%dx),%al
f01006d0:	0f b6 f0             	movzbl %al,%esi
f01006d3:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006db:	89 ca                	mov    %ecx,%edx
f01006dd:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006de:	89 da                	mov    %ebx,%edx
f01006e0:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006e1:	89 3d 2c 12 23 f0    	mov    %edi,0xf023122c
	pos |= inb(addr_6845 + 1);
f01006e7:	0f b6 d8             	movzbl %al,%ebx
f01006ea:	09 de                	or     %ebx,%esi
	crt_pos = pos;
f01006ec:	66 89 35 28 12 23 f0 	mov    %si,0xf0231228
	kbd_intr();
f01006f3:	e8 1b ff ff ff       	call   f0100613 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006f8:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006ff:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100704:	89 04 24             	mov    %eax,(%esp)
f0100707:	e8 05 3b 00 00       	call   f0104211 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010070c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100711:	b8 00 00 00 00       	mov    $0x0,%eax
f0100716:	89 f2                	mov    %esi,%edx
f0100718:	ee                   	out    %al,(%dx)
f0100719:	b2 fb                	mov    $0xfb,%dl
f010071b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100720:	ee                   	out    %al,(%dx)
f0100721:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100726:	b8 0c 00 00 00       	mov    $0xc,%eax
f010072b:	89 da                	mov    %ebx,%edx
f010072d:	ee                   	out    %al,(%dx)
f010072e:	b2 f9                	mov    $0xf9,%dl
f0100730:	b8 00 00 00 00       	mov    $0x0,%eax
f0100735:	ee                   	out    %al,(%dx)
f0100736:	b2 fb                	mov    $0xfb,%dl
f0100738:	b8 03 00 00 00       	mov    $0x3,%eax
f010073d:	ee                   	out    %al,(%dx)
f010073e:	b2 fc                	mov    $0xfc,%dl
f0100740:	b8 00 00 00 00       	mov    $0x0,%eax
f0100745:	ee                   	out    %al,(%dx)
f0100746:	b2 f9                	mov    $0xf9,%dl
f0100748:	b8 01 00 00 00       	mov    $0x1,%eax
f010074d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010074e:	b2 fd                	mov    $0xfd,%dl
f0100750:	ec                   	in     (%dx),%al
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100751:	3c ff                	cmp    $0xff,%al
f0100753:	0f 95 c1             	setne  %cl
f0100756:	88 0d 34 12 23 f0    	mov    %cl,0xf0231234
f010075c:	89 f2                	mov    %esi,%edx
f010075e:	ec                   	in     (%dx),%al
f010075f:	89 da                	mov    %ebx,%edx
f0100761:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100762:	84 c9                	test   %cl,%cl
f0100764:	75 0c                	jne    f0100772 <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f0100766:	c7 04 24 b1 73 10 f0 	movl   $0xf01073b1,(%esp)
f010076d:	e8 de 3b 00 00       	call   f0104350 <cprintf>
}
f0100772:	83 c4 1c             	add    $0x1c,%esp
f0100775:	5b                   	pop    %ebx
f0100776:	5e                   	pop    %esi
f0100777:	5f                   	pop    %edi
f0100778:	5d                   	pop    %ebp
f0100779:	c3                   	ret    

f010077a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010077a:	55                   	push   %ebp
f010077b:	89 e5                	mov    %esp,%ebp
f010077d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100780:	8b 45 08             	mov    0x8(%ebp),%eax
f0100783:	e8 8f fc ff ff       	call   f0100417 <cons_putc>
}
f0100788:	c9                   	leave  
f0100789:	c3                   	ret    

f010078a <getchar>:

int
getchar(void)
{
f010078a:	55                   	push   %ebp
f010078b:	89 e5                	mov    %esp,%ebp
f010078d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100790:	e8 90 fe ff ff       	call   f0100625 <cons_getc>
f0100795:	85 c0                	test   %eax,%eax
f0100797:	74 f7                	je     f0100790 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100799:	c9                   	leave  
f010079a:	c3                   	ret    

f010079b <iscons>:

int
iscons(int fdnum)
{
f010079b:	55                   	push   %ebp
f010079c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010079e:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a3:	5d                   	pop    %ebp
f01007a4:	c3                   	ret    
f01007a5:	66 90                	xchg   %ax,%ax
f01007a7:	66 90                	xchg   %ax,%ax
f01007a9:	66 90                	xchg   %ax,%ax
f01007ab:	66 90                	xchg   %ax,%ax
f01007ad:	66 90                	xchg   %ax,%ax
f01007af:	90                   	nop

f01007b0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007b0:	55                   	push   %ebp
f01007b1:	89 e5                	mov    %esp,%ebp
f01007b3:	56                   	push   %esi
f01007b4:	53                   	push   %ebx
f01007b5:	83 ec 10             	sub    $0x10,%esp
f01007b8:	bb 84 7b 10 f0       	mov    $0xf0107b84,%ebx
f01007bd:	be d8 7b 10 f0       	mov    $0xf0107bd8,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007c2:	8b 03                	mov    (%ebx),%eax
f01007c4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007c8:	8b 43 fc             	mov    -0x4(%ebx),%eax
f01007cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007cf:	c7 04 24 00 76 10 f0 	movl   $0xf0107600,(%esp)
f01007d6:	e8 75 3b 00 00       	call   f0104350 <cprintf>
f01007db:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01007de:	39 f3                	cmp    %esi,%ebx
f01007e0:	75 e0                	jne    f01007c2 <mon_help+0x12>
	return 0;
}
f01007e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e7:	83 c4 10             	add    $0x10,%esp
f01007ea:	5b                   	pop    %ebx
f01007eb:	5e                   	pop    %esi
f01007ec:	5d                   	pop    %ebp
f01007ed:	c3                   	ret    

f01007ee <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007ee:	55                   	push   %ebp
f01007ef:	89 e5                	mov    %esp,%ebp
f01007f1:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007f4:	c7 04 24 09 76 10 f0 	movl   $0xf0107609,(%esp)
f01007fb:	e8 50 3b 00 00       	call   f0104350 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100800:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100807:	00 
f0100808:	c7 04 24 d0 77 10 f0 	movl   $0xf01077d0,(%esp)
f010080f:	e8 3c 3b 00 00       	call   f0104350 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100814:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010081b:	00 
f010081c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100823:	f0 
f0100824:	c7 04 24 f8 77 10 f0 	movl   $0xf01077f8,(%esp)
f010082b:	e8 20 3b 00 00       	call   f0104350 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100830:	c7 44 24 08 d7 72 10 	movl   $0x1072d7,0x8(%esp)
f0100837:	00 
f0100838:	c7 44 24 04 d7 72 10 	movl   $0xf01072d7,0x4(%esp)
f010083f:	f0 
f0100840:	c7 04 24 1c 78 10 f0 	movl   $0xf010781c,(%esp)
f0100847:	e8 04 3b 00 00       	call   f0104350 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084c:	c7 44 24 08 00 10 23 	movl   $0x231000,0x8(%esp)
f0100853:	00 
f0100854:	c7 44 24 04 00 10 23 	movl   $0xf0231000,0x4(%esp)
f010085b:	f0 
f010085c:	c7 04 24 40 78 10 f0 	movl   $0xf0107840,(%esp)
f0100863:	e8 e8 3a 00 00       	call   f0104350 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100868:	c7 44 24 08 08 30 27 	movl   $0x273008,0x8(%esp)
f010086f:	00 
f0100870:	c7 44 24 04 08 30 27 	movl   $0xf0273008,0x4(%esp)
f0100877:	f0 
f0100878:	c7 04 24 64 78 10 f0 	movl   $0xf0107864,(%esp)
f010087f:	e8 cc 3a 00 00       	call   f0104350 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100884:	b8 07 34 27 f0       	mov    $0xf0273407,%eax
f0100889:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010088e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100893:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100899:	85 c0                	test   %eax,%eax
f010089b:	0f 48 c2             	cmovs  %edx,%eax
f010089e:	c1 f8 0a             	sar    $0xa,%eax
f01008a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a5:	c7 04 24 88 78 10 f0 	movl   $0xf0107888,(%esp)
f01008ac:	e8 9f 3a 00 00       	call   f0104350 <cprintf>
	return 0;
}
f01008b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b6:	c9                   	leave  
f01008b7:	c3                   	ret    

f01008b8 <mon_color>:
    return 0;
}

int
mon_color(int argc, char **argv, struct Trapframe *tf)
{
f01008b8:	55                   	push   %ebp
f01008b9:	89 e5                	mov    %esp,%ebp
f01008bb:	83 ec 18             	sub    $0x18,%esp
	// Print many colors
    cprintf("\33[0;33mCyan \33[0;35mGreen \33[0;36mPurple \33[0;31mBlue  \33[0;32mRed ");
f01008be:	c7 04 24 b4 78 10 f0 	movl   $0xf01078b4,(%esp)
f01008c5:	e8 86 3a 00 00       	call   f0104350 <cprintf>
	cprintf("\33[0;34mYellow \n");
f01008ca:	c7 04 24 22 76 10 f0 	movl   $0xf0107622,(%esp)
f01008d1:	e8 7a 3a 00 00       	call   f0104350 <cprintf>

	// Reset color
	cprintf("\33[0;0m"); 
f01008d6:	c7 04 24 32 76 10 f0 	movl   $0xf0107632,(%esp)
f01008dd:	e8 6e 3a 00 00       	call   f0104350 <cprintf>

  return 0;
}
f01008e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e7:	c9                   	leave  
f01008e8:	c3                   	ret    

f01008e9 <mon_backtrace>:
{
f01008e9:	55                   	push   %ebp
f01008ea:	89 e5                	mov    %esp,%ebp
f01008ec:	57                   	push   %edi
f01008ed:	56                   	push   %esi
f01008ee:	53                   	push   %ebx
f01008ef:	83 ec 4c             	sub    $0x4c,%esp
	cprintf("Stack backtrace:\n");
f01008f2:	c7 04 24 39 76 10 f0 	movl   $0xf0107639,(%esp)
f01008f9:	e8 52 3a 00 00       	call   f0104350 <cprintf>
	int *ebp = (int *)read_ebp();
f01008fe:	89 eb                	mov    %ebp,%ebx
        if (debuginfo_eip(eip, &info) == 0) {
f0100900:	8d 7d d0             	lea    -0x30(%ebp),%edi
    while (ebp != 0){
f0100903:	eb 7b                	jmp    f0100980 <mon_backtrace+0x97>
        int eip = ebp[1];
f0100905:	8b 73 04             	mov    0x4(%ebx),%esi
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
f0100908:	8b 43 18             	mov    0x18(%ebx),%eax
f010090b:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010090f:	8b 43 14             	mov    0x14(%ebx),%eax
f0100912:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100916:	8b 43 10             	mov    0x10(%ebx),%eax
f0100919:	89 44 24 14          	mov    %eax,0x14(%esp)
f010091d:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100920:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100924:	8b 43 08             	mov    0x8(%ebx),%eax
f0100927:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010092b:	89 74 24 08          	mov    %esi,0x8(%esp)
f010092f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100933:	c7 04 24 f4 78 10 f0 	movl   $0xf01078f4,(%esp)
f010093a:	e8 11 3a 00 00       	call   f0104350 <cprintf>
        if (debuginfo_eip(eip, &info) == 0) {
f010093f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100943:	89 34 24             	mov    %esi,(%esp)
f0100946:	e8 2d 51 00 00       	call   f0105a78 <debuginfo_eip>
f010094b:	85 c0                	test   %eax,%eax
f010094d:	75 2f                	jne    f010097e <mon_backtrace+0x95>
            cprintf("         %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
f010094f:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100952:	89 74 24 14          	mov    %esi,0x14(%esp)
f0100956:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100959:	89 44 24 10          	mov    %eax,0x10(%esp)
f010095d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100960:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100964:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100967:	89 44 24 08          	mov    %eax,0x8(%esp)
f010096b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010096e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100972:	c7 04 24 4b 76 10 f0 	movl   $0xf010764b,(%esp)
f0100979:	e8 d2 39 00 00       	call   f0104350 <cprintf>
        ebp = (int *)(*ebp);
f010097e:	8b 1b                	mov    (%ebx),%ebx
    while (ebp != 0){
f0100980:	85 db                	test   %ebx,%ebx
f0100982:	75 81                	jne    f0100905 <mon_backtrace+0x1c>
}
f0100984:	b8 00 00 00 00       	mov    $0x0,%eax
f0100989:	83 c4 4c             	add    $0x4c,%esp
f010098c:	5b                   	pop    %ebx
f010098d:	5e                   	pop    %esi
f010098e:	5f                   	pop    %edi
f010098f:	5d                   	pop    %ebp
f0100990:	c3                   	ret    

f0100991 <mon_memdump>:

	return 0;
}
int 
mon_memdump(int argc, char **argv, struct Trapframe *tf)
{
f0100991:	55                   	push   %ebp
f0100992:	89 e5                	mov    %esp,%ebp
f0100994:	57                   	push   %edi
f0100995:	56                   	push   %esi
f0100996:	53                   	push   %ebx
f0100997:	83 ec 1c             	sub    $0x1c,%esp
f010099a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc < 3)
f010099d:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f01009a1:	7f 1d                	jg     f01009c0 <mon_memdump+0x2f>
	{
		cprintf("\33[0;35mNot proper user input.\n");
f01009a3:	c7 04 24 2c 79 10 f0 	movl   $0xf010792c,(%esp)
f01009aa:	e8 a1 39 00 00       	call   f0104350 <cprintf>
		cprintf("\33[0;31mTip: \33[0;0mmemdump 0xLowAddr 0xHighAddr \n");
f01009af:	c7 04 24 4c 79 10 f0 	movl   $0xf010794c,(%esp)
f01009b6:	e8 95 39 00 00       	call   f0104350 <cprintf>
		return 0;
f01009bb:	e9 d1 00 00 00       	jmp    f0100a91 <mon_memdump+0x100>
	}

	uintptr_t lo = ROUNDDOWN(strtol(argv[1], NULL, 16), 16);
f01009c0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01009c7:	00 
f01009c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009cf:	00 
f01009d0:	8b 43 04             	mov    0x4(%ebx),%eax
f01009d3:	89 04 24             	mov    %eax,(%esp)
f01009d6:	e8 08 5d 00 00       	call   f01066e3 <strtol>
f01009db:	83 e0 f0             	and    $0xfffffff0,%eax
f01009de:	89 c6                	mov    %eax,%esi
	uintptr_t hi = ROUNDDOWN(strtol(argv[2], NULL, 16), 16);
f01009e0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01009e7:	00 
f01009e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009ef:	00 
f01009f0:	8b 43 08             	mov    0x8(%ebx),%eax
f01009f3:	89 04 24             	mov    %eax,(%esp)
f01009f6:	e8 e8 5c 00 00       	call   f01066e3 <strtol>
f01009fb:	83 e0 f0             	and    $0xfffffff0,%eax
f01009fe:	89 c7                	mov    %eax,%edi

	for (uintptr_t i = lo; i <= hi; i += 16)
f0100a00:	e9 84 00 00 00       	jmp    f0100a89 <mon_memdump+0xf8>
	{
		struct PageInfo *pp = page_lookup(kern_pgdir, (void *)i, NULL);	
f0100a05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100a0c:	00 
f0100a0d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a11:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0100a16:	89 04 24             	mov    %eax,(%esp)
f0100a19:	e8 e6 0c 00 00       	call   f0101704 <page_lookup>
		if (!pp)
f0100a1e:	85 c0                	test   %eax,%eax
f0100a20:	75 0e                	jne    f0100a30 <mon_memdump+0x9f>
		{
			cprintf("Not exist\n");
f0100a22:	c7 04 24 64 76 10 f0 	movl   $0xf0107664,(%esp)
f0100a29:	e8 22 39 00 00       	call   f0104350 <cprintf>
			continue;
f0100a2e:	eb 56                	jmp    f0100a86 <mon_memdump+0xf5>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a30:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0100a36:	c1 f8 03             	sar    $0x3,%eax
f0100a39:	c1 e0 0c             	shl    $0xc,%eax
		}
		else
		{
			cprintf("Vaddr: [%08x], Paddr: [%08x] - ", i, page2pa(pp)+PGOFF(i));
f0100a3c:	89 f2                	mov    %esi,%edx
f0100a3e:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0100a44:	01 d0                	add    %edx,%eax
f0100a46:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a4a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a4e:	c7 04 24 80 79 10 f0 	movl   $0xf0107980,(%esp)
f0100a55:	e8 f6 38 00 00       	call   f0104350 <cprintf>
			for (int j = 0; j < 16; j += 4)
f0100a5a:	bb 00 00 00 00       	mov    $0x0,%ebx
			{
				cprintf("%08lx ", *(long *)(i+j));
f0100a5f:	8b 04 33             	mov    (%ebx,%esi,1),%eax
f0100a62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a66:	c7 04 24 6f 76 10 f0 	movl   $0xf010766f,(%esp)
f0100a6d:	e8 de 38 00 00       	call   f0104350 <cprintf>
			for (int j = 0; j < 16; j += 4)
f0100a72:	83 c3 04             	add    $0x4,%ebx
f0100a75:	83 fb 10             	cmp    $0x10,%ebx
f0100a78:	75 e5                	jne    f0100a5f <mon_memdump+0xce>
			}
			cprintf("\n");
f0100a7a:	c7 04 24 30 76 10 f0 	movl   $0xf0107630,(%esp)
f0100a81:	e8 ca 38 00 00       	call   f0104350 <cprintf>
	for (uintptr_t i = lo; i <= hi; i += 16)
f0100a86:	83 c6 10             	add    $0x10,%esi
f0100a89:	39 fe                	cmp    %edi,%esi
f0100a8b:	0f 86 74 ff ff ff    	jbe    f0100a05 <mon_memdump+0x74>
		}
			
	}

	return 0;
}
f0100a91:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a96:	83 c4 1c             	add    $0x1c,%esp
f0100a99:	5b                   	pop    %ebx
f0100a9a:	5e                   	pop    %esi
f0100a9b:	5f                   	pop    %edi
f0100a9c:	5d                   	pop    %ebp
f0100a9d:	c3                   	ret    

f0100a9e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100a9e:	55                   	push   %ebp
f0100a9f:	89 e5                	mov    %esp,%ebp
f0100aa1:	57                   	push   %edi
f0100aa2:	56                   	push   %esi
f0100aa3:	53                   	push   %ebx
f0100aa4:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100aa7:	c7 04 24 a0 79 10 f0 	movl   $0xf01079a0,(%esp)
f0100aae:	e8 9d 38 00 00       	call   f0104350 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ab3:	c7 04 24 c4 79 10 f0 	movl   $0xf01079c4,(%esp)
f0100aba:	e8 91 38 00 00       	call   f0104350 <cprintf>

	if (tf != NULL)
f0100abf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100ac3:	74 0b                	je     f0100ad0 <monitor+0x32>
		print_trapframe(tf);
f0100ac5:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ac8:	89 04 24             	mov    %eax,(%esp)
f0100acb:	e8 14 40 00 00       	call   f0104ae4 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100ad0:	c7 04 24 76 76 10 f0 	movl   $0xf0107676,(%esp)
f0100ad7:	e8 84 58 00 00       	call   f0106360 <readline>
f0100adc:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100ade:	85 c0                	test   %eax,%eax
f0100ae0:	74 ee                	je     f0100ad0 <monitor+0x32>
	argv[argc] = 0;
f0100ae2:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100ae9:	be 00 00 00 00       	mov    $0x0,%esi
f0100aee:	eb 0a                	jmp    f0100afa <monitor+0x5c>
			*buf++ = 0;
f0100af0:	c6 03 00             	movb   $0x0,(%ebx)
f0100af3:	89 f7                	mov    %esi,%edi
f0100af5:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100af8:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100afa:	0f b6 03             	movzbl (%ebx),%eax
f0100afd:	84 c0                	test   %al,%al
f0100aff:	74 63                	je     f0100b64 <monitor+0xc6>
f0100b01:	0f be c0             	movsbl %al,%eax
f0100b04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b08:	c7 04 24 7a 76 10 f0 	movl   $0xf010767a,(%esp)
f0100b0f:	e8 66 5a 00 00       	call   f010657a <strchr>
f0100b14:	85 c0                	test   %eax,%eax
f0100b16:	75 d8                	jne    f0100af0 <monitor+0x52>
		if (*buf == 0)
f0100b18:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b1b:	74 47                	je     f0100b64 <monitor+0xc6>
		if (argc == MAXARGS-1) {
f0100b1d:	83 fe 0f             	cmp    $0xf,%esi
f0100b20:	75 16                	jne    f0100b38 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b22:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100b29:	00 
f0100b2a:	c7 04 24 7f 76 10 f0 	movl   $0xf010767f,(%esp)
f0100b31:	e8 1a 38 00 00       	call   f0104350 <cprintf>
f0100b36:	eb 98                	jmp    f0100ad0 <monitor+0x32>
		argv[argc++] = buf;
f0100b38:	8d 7e 01             	lea    0x1(%esi),%edi
f0100b3b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100b3f:	eb 03                	jmp    f0100b44 <monitor+0xa6>
			buf++;
f0100b41:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b44:	0f b6 03             	movzbl (%ebx),%eax
f0100b47:	84 c0                	test   %al,%al
f0100b49:	74 ad                	je     f0100af8 <monitor+0x5a>
f0100b4b:	0f be c0             	movsbl %al,%eax
f0100b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b52:	c7 04 24 7a 76 10 f0 	movl   $0xf010767a,(%esp)
f0100b59:	e8 1c 5a 00 00       	call   f010657a <strchr>
f0100b5e:	85 c0                	test   %eax,%eax
f0100b60:	74 df                	je     f0100b41 <monitor+0xa3>
f0100b62:	eb 94                	jmp    f0100af8 <monitor+0x5a>
	argv[argc] = 0;
f0100b64:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100b6b:	00 
	if (argc == 0)
f0100b6c:	85 f6                	test   %esi,%esi
f0100b6e:	0f 84 5c ff ff ff    	je     f0100ad0 <monitor+0x32>
f0100b74:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100b79:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b7c:	8b 04 85 80 7b 10 f0 	mov    -0xfef8480(,%eax,4),%eax
f0100b83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b87:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100b8a:	89 04 24             	mov    %eax,(%esp)
f0100b8d:	e8 8a 59 00 00       	call   f010651c <strcmp>
f0100b92:	85 c0                	test   %eax,%eax
f0100b94:	75 24                	jne    f0100bba <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100b96:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b99:	8b 55 08             	mov    0x8(%ebp),%edx
f0100b9c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ba0:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100ba3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100ba7:	89 34 24             	mov    %esi,(%esp)
f0100baa:	ff 14 85 88 7b 10 f0 	call   *-0xfef8478(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100bb1:	85 c0                	test   %eax,%eax
f0100bb3:	78 25                	js     f0100bda <monitor+0x13c>
f0100bb5:	e9 16 ff ff ff       	jmp    f0100ad0 <monitor+0x32>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100bba:	83 c3 01             	add    $0x1,%ebx
f0100bbd:	83 fb 07             	cmp    $0x7,%ebx
f0100bc0:	75 b7                	jne    f0100b79 <monitor+0xdb>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100bc2:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bc9:	c7 04 24 9c 76 10 f0 	movl   $0xf010769c,(%esp)
f0100bd0:	e8 7b 37 00 00       	call   f0104350 <cprintf>
f0100bd5:	e9 f6 fe ff ff       	jmp    f0100ad0 <monitor+0x32>
				break;
	}
}
f0100bda:	83 c4 5c             	add    $0x5c,%esp
f0100bdd:	5b                   	pop    %ebx
f0100bde:	5e                   	pop    %esi
f0100bdf:	5f                   	pop    %edi
f0100be0:	5d                   	pop    %ebp
f0100be1:	c3                   	ret    

f0100be2 <hexStoi>:

		/***** helper functions *****/

uint32_t 
hexStoi(char *buf)
{
f0100be2:	55                   	push   %ebp
f0100be3:	89 e5                	mov    %esp,%ebp
f0100be5:	53                   	push   %ebx
	uint32_t result = 0;

	// To skip "0x"
	buf += 2;
f0100be6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100be9:	8d 50 02             	lea    0x2(%eax),%edx
	uint32_t result = 0;
f0100bec:	b8 00 00 00 00       	mov    $0x0,%eax

	while (*buf)
f0100bf1:	eb 1a                	jmp    f0100c0d <hexStoi+0x2b>
	{
		if ( (*buf >= 'a') & (*buf <= 'f')){
f0100bf3:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0100bf6:	80 fb 05             	cmp    $0x5,%bl
f0100bf9:	77 05                	ja     f0100c00 <hexStoi+0x1e>
			// cprintf("Before *buf: %d\n", *buf);
			// cprintf("*buf - 'a': %d\n", *buf-'a');
			// cprintf("*buf - 'a' + '0': %d\n", *buf-'a'+'0');
			// cprintf("*buf - 'a' + '0'+10: %d\n", *buf-'a'+'0'+10);
			*buf = *buf-'a'+'0'+10;
f0100bfb:	83 e9 27             	sub    $0x27,%ecx
f0100bfe:	88 0a                	mov    %cl,(%edx)
			// cprintf("After *buf: %d\n", *buf);
		}
		
		// cprintf("result*16: %d\n", result*16);
		// cprintf("*buf-'0': %d\n", *buf-'0');
		result = result * 16 + *buf - '0';
f0100c00:	c1 e0 04             	shl    $0x4,%eax
f0100c03:	0f be 0a             	movsbl (%edx),%ecx
f0100c06:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
		// cprintf("result: %d\n", result);
		buf++;
f0100c0a:	83 c2 01             	add    $0x1,%edx
	while (*buf)
f0100c0d:	0f b6 0a             	movzbl (%edx),%ecx
f0100c10:	84 c9                	test   %cl,%cl
f0100c12:	75 df                	jne    f0100bf3 <hexStoi+0x11>
	}

	return result;
}
f0100c14:	5b                   	pop    %ebx
f0100c15:	5d                   	pop    %ebp
f0100c16:	c3                   	ret    

f0100c17 <mon_showmappings>:
{
f0100c17:	55                   	push   %ebp
f0100c18:	89 e5                	mov    %esp,%ebp
f0100c1a:	57                   	push   %edi
f0100c1b:	56                   	push   %esi
f0100c1c:	53                   	push   %ebx
f0100c1d:	83 ec 1c             	sub    $0x1c,%esp
f0100c20:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2){
f0100c23:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100c27:	7f 11                	jg     f0100c3a <mon_showmappings+0x23>
		cprintf("Not proper user input. Need two address\n");
f0100c29:	c7 04 24 ec 79 10 f0 	movl   $0xf01079ec,(%esp)
f0100c30:	e8 1b 37 00 00       	call   f0104350 <cprintf>
		return 0;
f0100c35:	e9 d4 00 00 00       	jmp    f0100d0e <mon_showmappings+0xf7>
	uint32_t start = hexStoi(argv[1]);
f0100c3a:	8b 46 04             	mov    0x4(%esi),%eax
f0100c3d:	89 04 24             	mov    %eax,(%esp)
f0100c40:	e8 9d ff ff ff       	call   f0100be2 <hexStoi>
f0100c45:	89 c3                	mov    %eax,%ebx
	uint32_t end = hexStoi(argv[2]);
f0100c47:	8b 46 08             	mov    0x8(%esi),%eax
f0100c4a:	89 04 24             	mov    %eax,(%esp)
f0100c4d:	e8 90 ff ff ff       	call   f0100be2 <hexStoi>
f0100c52:	89 c7                	mov    %eax,%edi
	cprintf("start: 0x%x, end: 0x%x\n", start, end);
f0100c54:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100c5c:	c7 04 24 b2 76 10 f0 	movl   $0xf01076b2,(%esp)
f0100c63:	e8 e8 36 00 00       	call   f0104350 <cprintf>
	for (start ; start <= end; start += PGSIZE)
f0100c68:	e9 99 00 00 00       	jmp    f0100d06 <mon_showmappings+0xef>
		pte_t *p_pte = pgdir_walk(kern_pgdir, (void *) start, 1);
f0100c6d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100c74:	00 
f0100c75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100c79:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0100c7e:	89 04 24             	mov    %eax,(%esp)
f0100c81:	e8 12 09 00 00       	call   f0101598 <pgdir_walk>
f0100c86:	89 c6                	mov    %eax,%esi
		if (!p_pte) 
f0100c88:	85 c0                	test   %eax,%eax
f0100c8a:	75 1c                	jne    f0100ca8 <mon_showmappings+0x91>
			panic("mon_showmappings: No p_pte");
f0100c8c:	c7 44 24 08 ca 76 10 	movl   $0xf01076ca,0x8(%esp)
f0100c93:	f0 
f0100c94:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
f0100c9b:	00 
f0100c9c:	c7 04 24 e5 76 10 f0 	movl   $0xf01076e5,(%esp)
f0100ca3:	e8 98 f3 ff ff       	call   f0100040 <_panic>
		if (*p_pte & PTE_P)
f0100ca8:	8b 00                	mov    (%eax),%eax
f0100caa:	a8 01                	test   $0x1,%al
f0100cac:	74 42                	je     f0100cf0 <mon_showmappings+0xd9>
			cprintf("VADDR: %x, PHYSADDR: %08x  - ", start, PTE_ADDR(*p_pte));
f0100cae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cb3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cb7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100cbb:	c7 04 24 f4 76 10 f0 	movl   $0xf01076f4,(%esp)
f0100cc2:	e8 89 36 00 00       	call   f0104350 <cprintf>
			cprintf(" PTE_P: %x, PTE_W: %x, PTE_U: %x \n", *p_pte&PTE_P, (*p_pte&PTE_W), (*p_pte&PTE_U));
f0100cc7:	8b 06                	mov    (%esi),%eax
f0100cc9:	89 c2                	mov    %eax,%edx
f0100ccb:	83 e2 04             	and    $0x4,%edx
f0100cce:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100cd2:	89 c2                	mov    %eax,%edx
f0100cd4:	83 e2 02             	and    $0x2,%edx
f0100cd7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100cdb:	83 e0 01             	and    $0x1,%eax
f0100cde:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ce2:	c7 04 24 18 7a 10 f0 	movl   $0xf0107a18,(%esp)
f0100ce9:	e8 62 36 00 00       	call   f0104350 <cprintf>
f0100cee:	eb 10                	jmp    f0100d00 <mon_showmappings+0xe9>
			cprintf("VADDR %x : not exist\n", start);
f0100cf0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100cf4:	c7 04 24 12 77 10 f0 	movl   $0xf0107712,(%esp)
f0100cfb:	e8 50 36 00 00       	call   f0104350 <cprintf>
	for (start ; start <= end; start += PGSIZE)
f0100d00:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100d06:	39 fb                	cmp    %edi,%ebx
f0100d08:	0f 86 5f ff ff ff    	jbe    f0100c6d <mon_showmappings+0x56>
}
f0100d0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d13:	83 c4 1c             	add    $0x1c,%esp
f0100d16:	5b                   	pop    %ebx
f0100d17:	5e                   	pop    %esi
f0100d18:	5f                   	pop    %edi
f0100d19:	5d                   	pop    %ebp
f0100d1a:	c3                   	ret    

f0100d1b <mon_cmemp>:
{
f0100d1b:	55                   	push   %ebp
f0100d1c:	89 e5                	mov    %esp,%ebp
f0100d1e:	57                   	push   %edi
f0100d1f:	56                   	push   %esi
f0100d20:	53                   	push   %ebx
f0100d21:	83 ec 2c             	sub    $0x2c,%esp
f0100d24:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 3){
f0100d27:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100d2b:	7f 1d                	jg     f0100d4a <mon_cmemp+0x2f>
		cprintf("\33[0;35mNot proper user input.\n");
f0100d2d:	c7 04 24 2c 79 10 f0 	movl   $0xf010792c,(%esp)
f0100d34:	e8 17 36 00 00       	call   f0104350 <cprintf>
		cprintf("\33[0;31mTip: \33[0;0mcmemp 0xAddr [1|0] [p|w|u]\n");
f0100d39:	c7 04 24 3c 7a 10 f0 	movl   $0xf0107a3c,(%esp)
f0100d40:	e8 0b 36 00 00       	call   f0104350 <cprintf>
		return 0;
f0100d45:	e9 22 01 00 00       	jmp    f0100e6c <mon_cmemp+0x151>
	uint32_t addr = hexStoi(argv[1]);
f0100d4a:	8b 46 04             	mov    0x4(%esi),%eax
f0100d4d:	89 04 24             	mov    %eax,(%esp)
f0100d50:	e8 8d fe ff ff       	call   f0100be2 <hexStoi>
f0100d55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t *p_pte = pgdir_walk(kern_pgdir, (void *) addr, 1);
f0100d58:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100d5f:	00 
f0100d60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d64:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0100d69:	89 04 24             	mov    %eax,(%esp)
f0100d6c:	e8 27 08 00 00       	call   f0101598 <pgdir_walk>
f0100d71:	89 c3                	mov    %eax,%ebx
	if (!p_pte) 
f0100d73:	85 c0                	test   %eax,%eax
f0100d75:	75 1c                	jne    f0100d93 <mon_cmemp+0x78>
		panic("mon_cmemp: No p_pte");
f0100d77:	c7 44 24 08 28 77 10 	movl   $0xf0107728,0x8(%esp)
f0100d7e:	f0 
f0100d7f:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0100d86:	00 
f0100d87:	c7 04 24 e5 76 10 f0 	movl   $0xf01076e5,(%esp)
f0100d8e:	e8 ad f2 ff ff       	call   f0100040 <_panic>
	cprintf("\33[0;31m[Before] \33[0;0mVADDR: %x , PHYSADDR: %08x  - ", addr, PTE_ADDR(*p_pte));
f0100d93:	8b 00                	mov    (%eax),%eax
f0100d95:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d9a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100da1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100da5:	c7 04 24 6c 7a 10 f0 	movl   $0xf0107a6c,(%esp)
f0100dac:	e8 9f 35 00 00       	call   f0104350 <cprintf>
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x \n", *p_pte&PTE_P, (*p_pte&PTE_W), (*p_pte&PTE_U));
f0100db1:	8b 03                	mov    (%ebx),%eax
f0100db3:	89 c2                	mov    %eax,%edx
f0100db5:	83 e2 04             	and    $0x4,%edx
f0100db8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100dbc:	89 c2                	mov    %eax,%edx
f0100dbe:	83 e2 02             	and    $0x2,%edx
f0100dc1:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100dc5:	83 e0 01             	and    $0x1,%eax
f0100dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dcc:	c7 04 24 a4 7a 10 f0 	movl   $0xf0107aa4,(%esp)
f0100dd3:	e8 78 35 00 00       	call   f0104350 <cprintf>
	uint32_t perm = 0;
f0100dd8:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i = 0;
f0100ddd:	ba 00 00 00 00       	mov    $0x0,%edx
		if ((argv[3][i]=='u') | (argv[3][i]=='U')) perm = PTE_U;
f0100de2:	bf 04 00 00 00       	mov    $0x4,%edi
	while (argv[3][i])
f0100de7:	eb 33                	jmp    f0100e1c <mon_cmemp+0x101>
		if ((argv[3][i]=='p') | (argv[3][i]=='P')) perm = PTE_P;
f0100de9:	83 e0 df             	and    $0xffffffdf,%eax
f0100dec:	3c 50                	cmp    $0x50,%al
f0100dee:	74 06                	je     f0100df6 <mon_cmemp+0xdb>
		if ((argv[3][i]=='w') | (argv[3][i]=='W')) perm = PTE_W;
f0100df0:	3c 57                	cmp    $0x57,%al
f0100df2:	74 0e                	je     f0100e02 <mon_cmemp+0xe7>
f0100df4:	eb 05                	jmp    f0100dfb <mon_cmemp+0xe0>
		if ((argv[3][i]=='p') | (argv[3][i]=='P')) perm = PTE_P;
f0100df6:	b9 01 00 00 00       	mov    $0x1,%ecx
		if ((argv[3][i]=='u') | (argv[3][i]=='U')) perm = PTE_U;
f0100dfb:	3c 55                	cmp    $0x55,%al
f0100dfd:	0f 44 cf             	cmove  %edi,%ecx
f0100e00:	eb 05                	jmp    f0100e07 <mon_cmemp+0xec>
		if ((argv[3][i]=='w') | (argv[3][i]=='W')) perm = PTE_W;
f0100e02:	b9 02 00 00 00       	mov    $0x2,%ecx
		if (argv[2][0]=='0')
f0100e07:	8b 46 08             	mov    0x8(%esi),%eax
f0100e0a:	80 38 30             	cmpb   $0x30,(%eax)
f0100e0d:	75 08                	jne    f0100e17 <mon_cmemp+0xfc>
			*p_pte = *p_pte & ~perm;
f0100e0f:	89 c8                	mov    %ecx,%eax
f0100e11:	f7 d0                	not    %eax
f0100e13:	21 03                	and    %eax,(%ebx)
f0100e15:	eb 02                	jmp    f0100e19 <mon_cmemp+0xfe>
			*p_pte = *p_pte | perm;
f0100e17:	09 0b                	or     %ecx,(%ebx)
		i++;
f0100e19:	83 c2 01             	add    $0x1,%edx
	while (argv[3][i])
f0100e1c:	8b 46 0c             	mov    0xc(%esi),%eax
f0100e1f:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
f0100e23:	84 c0                	test   %al,%al
f0100e25:	75 c2                	jne    f0100de9 <mon_cmemp+0xce>
	cprintf("\33[0;31m[After] \33[0;0mVADDR: %x , PHYSADDR: %08x  - ", addr, PTE_ADDR(*p_pte));
f0100e27:	8b 03                	mov    (%ebx),%eax
f0100e29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e2e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e35:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e39:	c7 04 24 c8 7a 10 f0 	movl   $0xf0107ac8,(%esp)
f0100e40:	e8 0b 35 00 00       	call   f0104350 <cprintf>
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x \n", *p_pte&PTE_P, (*p_pte&PTE_W), (*p_pte&PTE_U));
f0100e45:	8b 03                	mov    (%ebx),%eax
f0100e47:	89 c2                	mov    %eax,%edx
f0100e49:	83 e2 04             	and    $0x4,%edx
f0100e4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100e50:	89 c2                	mov    %eax,%edx
f0100e52:	83 e2 02             	and    $0x2,%edx
f0100e55:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100e59:	83 e0 01             	and    $0x1,%eax
f0100e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e60:	c7 04 24 a4 7a 10 f0 	movl   $0xf0107aa4,(%esp)
f0100e67:	e8 e4 34 00 00       	call   f0104350 <cprintf>
}
f0100e6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e71:	83 c4 2c             	add    $0x2c,%esp
f0100e74:	5b                   	pop    %ebx
f0100e75:	5e                   	pop    %esi
f0100e76:	5f                   	pop    %edi
f0100e77:	5d                   	pop    %ebp
f0100e78:	c3                   	ret    
f0100e79:	66 90                	xchg   %ax,%ax
f0100e7b:	66 90                	xchg   %ax,%ax
f0100e7d:	66 90                	xchg   %ax,%ax
f0100e7f:	90                   	nop

f0100e80 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100e80:	55                   	push   %ebp
f0100e81:	89 e5                	mov    %esp,%ebp
f0100e83:	56                   	push   %esi
f0100e84:	53                   	push   %ebx
f0100e85:	83 ec 10             	sub    $0x10,%esp
f0100e88:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100e8a:	89 04 24             	mov    %eax,(%esp)
f0100e8d:	e8 55 33 00 00       	call   f01041e7 <mc146818_read>
f0100e92:	89 c6                	mov    %eax,%esi
f0100e94:	83 c3 01             	add    $0x1,%ebx
f0100e97:	89 1c 24             	mov    %ebx,(%esp)
f0100e9a:	e8 48 33 00 00       	call   f01041e7 <mc146818_read>
f0100e9f:	c1 e0 08             	shl    $0x8,%eax
f0100ea2:	09 f0                	or     %esi,%eax
}
f0100ea4:	83 c4 10             	add    $0x10,%esp
f0100ea7:	5b                   	pop    %ebx
f0100ea8:	5e                   	pop    %esi
f0100ea9:	5d                   	pop    %ebp
f0100eaa:	c3                   	ret    

f0100eab <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100eab:	83 3d 38 12 23 f0 00 	cmpl   $0x0,0xf0231238
f0100eb2:	75 6b                	jne    f0100f1f <boot_alloc+0x74>
		extern char end[];
		//nextfree = ROUNDUP((char *) end, PGSIZE);
		nextfree = ROUNDUP((char *) end + 1, PGSIZE);
f0100eb4:	ba 08 40 27 f0       	mov    $0xf0274008,%edx
f0100eb9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ebf:	89 15 38 12 23 f0    	mov    %edx,0xf0231238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	if ( n > 0 ){
f0100ec5:	85 c0                	test   %eax,%eax
f0100ec7:	74 4d                	je     f0100f16 <boot_alloc+0x6b>
		result = nextfree;
f0100ec9:	8b 0d 38 12 23 f0    	mov    0xf0231238,%ecx
		nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
f0100ecf:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100ed6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100edc:	89 15 38 12 23 f0    	mov    %edx,0xf0231238

		//cprintf("nextfree - KERNBASE = %d\n", ((uint32_t) nextfree - KERNBASE));
		//cprintf("npages = %d\n", npages);

		if ( ((uint32_t)nextfree - KERNBASE) > (npages * PGSIZE) ){
f0100ee2:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100ee8:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0100eed:	c1 e0 0c             	shl    $0xc,%eax
f0100ef0:	39 c2                	cmp    %eax,%edx
f0100ef2:	76 28                	jbe    f0100f1c <boot_alloc+0x71>
{
f0100ef4:	55                   	push   %ebp
f0100ef5:	89 e5                	mov    %esp,%ebp
f0100ef7:	83 ec 18             	sub    $0x18,%esp
			panic("boot_alloc: Out of memory\n");
f0100efa:	c7 44 24 08 d4 7b 10 	movl   $0xf0107bd4,0x8(%esp)
f0100f01:	f0 
f0100f02:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
f0100f09:	00 
f0100f0a:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0100f11:	e8 2a f1 ff ff       	call   f0100040 <_panic>
		}

		return result;
	}
	else if ( n == 0 ){
		return nextfree;
f0100f16:	a1 38 12 23 f0       	mov    0xf0231238,%eax
f0100f1b:	c3                   	ret    
		return result;
f0100f1c:	89 c8                	mov    %ecx,%eax
f0100f1e:	c3                   	ret    
	if ( n > 0 ){
f0100f1f:	85 c0                	test   %eax,%eax
f0100f21:	75 a6                	jne    f0100ec9 <boot_alloc+0x1e>
f0100f23:	eb f1                	jmp    f0100f16 <boot_alloc+0x6b>

f0100f25 <page2kva>:
f0100f25:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0100f2b:	c1 f8 03             	sar    $0x3,%eax
f0100f2e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100f31:	89 c2                	mov    %eax,%edx
f0100f33:	c1 ea 0c             	shr    $0xc,%edx
f0100f36:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0100f3c:	72 26                	jb     f0100f64 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100f3e:	55                   	push   %ebp
f0100f3f:	89 e5                	mov    %esp,%ebp
f0100f41:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f44:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f48:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0100f4f:	f0 
f0100f50:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f57:	00 
f0100f58:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f0100f5f:	e8 dc f0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100f64:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return KADDR(page2pa(pp));
}
f0100f69:	c3                   	ret    

f0100f6a <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f6a:	89 d1                	mov    %edx,%ecx
f0100f6c:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100f6f:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100f72:	a8 01                	test   $0x1,%al
f0100f74:	74 5d                	je     f0100fd3 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100f76:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100f7b:	89 c1                	mov    %eax,%ecx
f0100f7d:	c1 e9 0c             	shr    $0xc,%ecx
f0100f80:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0100f86:	72 26                	jb     f0100fae <check_va2pa+0x44>
{
f0100f88:	55                   	push   %ebp
f0100f89:	89 e5                	mov    %esp,%ebp
f0100f8b:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f92:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0100f99:	f0 
f0100f9a:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0100fa1:	00 
f0100fa2:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0100fa9:	e8 92 f0 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100fae:	c1 ea 0c             	shr    $0xc,%edx
f0100fb1:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100fb7:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100fbe:	89 c2                	mov    %eax,%edx
f0100fc0:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100fc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fc8:	85 d2                	test   %edx,%edx
f0100fca:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100fcf:	0f 44 c2             	cmove  %edx,%eax
f0100fd2:	c3                   	ret    
		return ~0;
f0100fd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100fd8:	c3                   	ret    

f0100fd9 <check_page_free_list>:
{
f0100fd9:	55                   	push   %ebp
f0100fda:	89 e5                	mov    %esp,%ebp
f0100fdc:	57                   	push   %edi
f0100fdd:	56                   	push   %esi
f0100fde:	53                   	push   %ebx
f0100fdf:	83 ec 4c             	sub    $0x4c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fe2:	84 c0                	test   %al,%al
f0100fe4:	0f 85 3f 03 00 00    	jne    f0101329 <check_page_free_list+0x350>
f0100fea:	e9 4c 03 00 00       	jmp    f010133b <check_page_free_list+0x362>
		panic("'page_free_list' is a null pointer!");
f0100fef:	c7 44 24 08 38 7f 10 	movl   $0xf0107f38,0x8(%esp)
f0100ff6:	f0 
f0100ff7:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0100ffe:	00 
f0100fff:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101006:	e8 35 f0 ff ff       	call   f0100040 <_panic>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010100b:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010100e:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101011:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101014:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101017:	89 c2                	mov    %eax,%edx
f0101019:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010101f:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0101025:	0f 95 c2             	setne  %dl
f0101028:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f010102b:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f010102f:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101031:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101035:	8b 00                	mov    (%eax),%eax
f0101037:	85 c0                	test   %eax,%eax
f0101039:	75 dc                	jne    f0101017 <check_page_free_list+0x3e>
		*tp[1] = 0;
f010103b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010103e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101044:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101047:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010104a:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f010104c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010104f:	a3 40 12 23 f0       	mov    %eax,0xf0231240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101054:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101059:	8b 1d 40 12 23 f0    	mov    0xf0231240,%ebx
f010105f:	eb 63                	jmp    f01010c4 <check_page_free_list+0xeb>
f0101061:	89 d8                	mov    %ebx,%eax
f0101063:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101069:	c1 f8 03             	sar    $0x3,%eax
f010106c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010106f:	89 c2                	mov    %eax,%edx
f0101071:	c1 ea 16             	shr    $0x16,%edx
f0101074:	39 f2                	cmp    %esi,%edx
f0101076:	73 4a                	jae    f01010c2 <check_page_free_list+0xe9>
	if (PGNUM(pa) >= npages)
f0101078:	89 c2                	mov    %eax,%edx
f010107a:	c1 ea 0c             	shr    $0xc,%edx
f010107d:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101083:	72 20                	jb     f01010a5 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101085:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101089:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0101090:	f0 
f0101091:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101098:	00 
f0101099:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f01010a0:	e8 9b ef ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01010a5:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01010ac:	00 
f01010ad:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01010b4:	00 
	return (void *)(pa + KERNBASE);
f01010b5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010ba:	89 04 24             	mov    %eax,(%esp)
f01010bd:	e8 f5 54 00 00       	call   f01065b7 <memset>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010c2:	8b 1b                	mov    (%ebx),%ebx
f01010c4:	85 db                	test   %ebx,%ebx
f01010c6:	75 99                	jne    f0101061 <check_page_free_list+0x88>
	first_free_page = (char *) boot_alloc(0);
f01010c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01010cd:	e8 d9 fd ff ff       	call   f0100eab <boot_alloc>
f01010d2:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010d5:	8b 15 40 12 23 f0    	mov    0xf0231240,%edx
		assert(pp >= pages);
f01010db:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
		assert(pp < pages + npages);
f01010e1:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f01010e6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01010e9:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f01010ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010ef:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f01010f2:	bf 00 00 00 00       	mov    $0x0,%edi
f01010f7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010fa:	e9 c4 01 00 00       	jmp    f01012c3 <check_page_free_list+0x2ea>
		assert(pp >= pages);
f01010ff:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101102:	73 24                	jae    f0101128 <check_page_free_list+0x14f>
f0101104:	c7 44 24 0c 09 7c 10 	movl   $0xf0107c09,0xc(%esp)
f010110b:	f0 
f010110c:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101113:	f0 
f0101114:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f010111b:	00 
f010111c:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101123:	e8 18 ef ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0101128:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010112b:	72 24                	jb     f0101151 <check_page_free_list+0x178>
f010112d:	c7 44 24 0c 2a 7c 10 	movl   $0xf0107c2a,0xc(%esp)
f0101134:	f0 
f0101135:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010113c:	f0 
f010113d:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0101144:	00 
f0101145:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010114c:	e8 ef ee ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101151:	89 d0                	mov    %edx,%eax
f0101153:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101156:	a8 07                	test   $0x7,%al
f0101158:	74 24                	je     f010117e <check_page_free_list+0x1a5>
f010115a:	c7 44 24 0c 5c 7f 10 	movl   $0xf0107f5c,0xc(%esp)
f0101161:	f0 
f0101162:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101169:	f0 
f010116a:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f0101171:	00 
f0101172:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101179:	e8 c2 ee ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f010117e:	c1 f8 03             	sar    $0x3,%eax
f0101181:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0101184:	85 c0                	test   %eax,%eax
f0101186:	75 24                	jne    f01011ac <check_page_free_list+0x1d3>
f0101188:	c7 44 24 0c 3e 7c 10 	movl   $0xf0107c3e,0xc(%esp)
f010118f:	f0 
f0101190:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101197:	f0 
f0101198:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f010119f:	00 
f01011a0:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01011a7:	e8 94 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01011ac:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011b1:	75 24                	jne    f01011d7 <check_page_free_list+0x1fe>
f01011b3:	c7 44 24 0c 4f 7c 10 	movl   $0xf0107c4f,0xc(%esp)
f01011ba:	f0 
f01011bb:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01011c2:	f0 
f01011c3:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f01011ca:	00 
f01011cb:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01011d2:	e8 69 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011d7:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01011dc:	75 24                	jne    f0101202 <check_page_free_list+0x229>
f01011de:	c7 44 24 0c 90 7f 10 	movl   $0xf0107f90,0xc(%esp)
f01011e5:	f0 
f01011e6:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01011ed:	f0 
f01011ee:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f01011f5:	00 
f01011f6:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01011fd:	e8 3e ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101202:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101207:	75 24                	jne    f010122d <check_page_free_list+0x254>
f0101209:	c7 44 24 0c 68 7c 10 	movl   $0xf0107c68,0xc(%esp)
f0101210:	f0 
f0101211:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101218:	f0 
f0101219:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0101220:	00 
f0101221:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101228:	e8 13 ee ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010122d:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101232:	0f 86 2a 01 00 00    	jbe    f0101362 <check_page_free_list+0x389>
	if (PGNUM(pa) >= npages)
f0101238:	89 c1                	mov    %eax,%ecx
f010123a:	c1 e9 0c             	shr    $0xc,%ecx
f010123d:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0101240:	77 20                	ja     f0101262 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101242:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101246:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f010124d:	f0 
f010124e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101255:	00 
f0101256:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f010125d:	e8 de ed ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101262:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0101268:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010126b:	0f 86 e1 00 00 00    	jbe    f0101352 <check_page_free_list+0x379>
f0101271:	c7 44 24 0c b4 7f 10 	movl   $0xf0107fb4,0xc(%esp)
f0101278:	f0 
f0101279:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101280:	f0 
f0101281:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101288:	00 
f0101289:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101290:	e8 ab ed ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101295:	c7 44 24 0c 82 7c 10 	movl   $0xf0107c82,0xc(%esp)
f010129c:	f0 
f010129d:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01012a4:	f0 
f01012a5:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f01012ac:	00 
f01012ad:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01012b4:	e8 87 ed ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f01012b9:	83 c3 01             	add    $0x1,%ebx
f01012bc:	eb 03                	jmp    f01012c1 <check_page_free_list+0x2e8>
			++nfree_extmem;
f01012be:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012c1:	8b 12                	mov    (%edx),%edx
f01012c3:	85 d2                	test   %edx,%edx
f01012c5:	0f 85 34 fe ff ff    	jne    f01010ff <check_page_free_list+0x126>
	assert(nfree_basemem > 0);
f01012cb:	85 db                	test   %ebx,%ebx
f01012cd:	7f 24                	jg     f01012f3 <check_page_free_list+0x31a>
f01012cf:	c7 44 24 0c 9f 7c 10 	movl   $0xf0107c9f,0xc(%esp)
f01012d6:	f0 
f01012d7:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01012de:	f0 
f01012df:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f01012e6:	00 
f01012e7:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01012ee:	e8 4d ed ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f01012f3:	85 ff                	test   %edi,%edi
f01012f5:	7f 24                	jg     f010131b <check_page_free_list+0x342>
f01012f7:	c7 44 24 0c b1 7c 10 	movl   $0xf0107cb1,0xc(%esp)
f01012fe:	f0 
f01012ff:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101306:	f0 
f0101307:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f010130e:	00 
f010130f:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101316:	e8 25 ed ff ff       	call   f0100040 <_panic>
	cprintf("check_page_free_list() succeeded!\n");
f010131b:	c7 04 24 fc 7f 10 f0 	movl   $0xf0107ffc,(%esp)
f0101322:	e8 29 30 00 00       	call   f0104350 <cprintf>
f0101327:	eb 4c                	jmp    f0101375 <check_page_free_list+0x39c>
	if (!page_free_list)
f0101329:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f010132e:	85 c0                	test   %eax,%eax
f0101330:	0f 85 d5 fc ff ff    	jne    f010100b <check_page_free_list+0x32>
f0101336:	e9 b4 fc ff ff       	jmp    f0100fef <check_page_free_list+0x16>
f010133b:	83 3d 40 12 23 f0 00 	cmpl   $0x0,0xf0231240
f0101342:	0f 84 a7 fc ff ff    	je     f0100fef <check_page_free_list+0x16>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101348:	be 00 04 00 00       	mov    $0x400,%esi
f010134d:	e9 07 fd ff ff       	jmp    f0101059 <check_page_free_list+0x80>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101352:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101357:	0f 85 61 ff ff ff    	jne    f01012be <check_page_free_list+0x2e5>
f010135d:	e9 33 ff ff ff       	jmp    f0101295 <check_page_free_list+0x2bc>
f0101362:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101367:	0f 85 4c ff ff ff    	jne    f01012b9 <check_page_free_list+0x2e0>
f010136d:	8d 76 00             	lea    0x0(%esi),%esi
f0101370:	e9 20 ff ff ff       	jmp    f0101295 <check_page_free_list+0x2bc>
}
f0101375:	83 c4 4c             	add    $0x4c,%esp
f0101378:	5b                   	pop    %ebx
f0101379:	5e                   	pop    %esi
f010137a:	5f                   	pop    %edi
f010137b:	5d                   	pop    %ebp
f010137c:	c3                   	ret    

f010137d <page_init>:
{
f010137d:	55                   	push   %ebp
f010137e:	89 e5                	mov    %esp,%ebp
f0101380:	56                   	push   %esi
f0101381:	53                   	push   %ebx
f0101382:	83 ec 10             	sub    $0x10,%esp
	pages[0].pp_ref = 1;
f0101385:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f010138a:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	for (i = PGSIZE / PGSIZE; i < (npages_basemem*PGSIZE) / PGSIZE; i++) {
f0101390:	8b 35 44 12 23 f0    	mov    0xf0231244,%esi
f0101396:	81 e6 ff ff 0f 00    	and    $0xfffff,%esi
f010139c:	8b 1d 40 12 23 f0    	mov    0xf0231240,%ebx
f01013a2:	b8 01 00 00 00       	mov    $0x1,%eax
f01013a7:	eb 3c                	jmp    f01013e5 <page_init+0x68>
		if ( i == (MPENTRY_PADDR / PGSIZE) ){
f01013a9:	83 f8 07             	cmp    $0x7,%eax
f01013ac:	75 15                	jne    f01013c3 <page_init+0x46>
			pages[i].pp_ref = 1;
f01013ae:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
f01013b4:	66 c7 42 3c 01 00    	movw   $0x1,0x3c(%edx)
			pages[i].pp_link = NULL;
f01013ba:	c7 42 38 00 00 00 00 	movl   $0x0,0x38(%edx)
f01013c1:	eb 1f                	jmp    f01013e2 <page_init+0x65>
f01013c3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f01013ca:	8b 0d 90 1e 23 f0    	mov    0xf0231e90,%ecx
f01013d0:	66 c7 44 11 04 00 00 	movw   $0x0,0x4(%ecx,%edx,1)
			pages[i].pp_link = page_free_list;
f01013d7:	89 1c c1             	mov    %ebx,(%ecx,%eax,8)
			page_free_list = &pages[i];
f01013da:	89 d3                	mov    %edx,%ebx
f01013dc:	03 1d 90 1e 23 f0    	add    0xf0231e90,%ebx
	for (i = PGSIZE / PGSIZE; i < (npages_basemem*PGSIZE) / PGSIZE; i++) {
f01013e2:	83 c0 01             	add    $0x1,%eax
f01013e5:	39 f0                	cmp    %esi,%eax
f01013e7:	72 c0                	jb     f01013a9 <page_init+0x2c>
f01013e9:	89 1d 40 12 23 f0    	mov    %ebx,0xf0231240
f01013ef:	b8 00 05 00 00       	mov    $0x500,%eax
		pages[i].pp_ref = 1;
f01013f4:	89 c2                	mov    %eax,%edx
f01013f6:	03 15 90 1e 23 f0    	add    0xf0231e90,%edx
f01013fc:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		pages[i].pp_link = NULL;
f0101402:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f0101408:	83 c0 08             	add    $0x8,%eax
	for (i = (IOPHYSMEM / PGSIZE); i < (EXTPHYSMEM / PGSIZE); i++){ 
f010140b:	3d 00 08 00 00       	cmp    $0x800,%eax
f0101410:	75 e2                	jne    f01013f4 <page_init+0x77>
f0101412:	bb 00 01 00 00       	mov    $0x100,%ebx
f0101417:	eb 7e                	jmp    f0101497 <page_init+0x11a>
		if ( i < PADDR(boot_alloc(0))/PGSIZE ){		
f0101419:	b8 00 00 00 00       	mov    $0x0,%eax
f010141e:	e8 88 fa ff ff       	call   f0100eab <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0101423:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101428:	77 20                	ja     f010144a <page_init+0xcd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010142a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010142e:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0101435:	f0 
f0101436:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
f010143d:	00 
f010143e:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101445:	e8 f6 eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010144a:	05 00 00 00 10       	add    $0x10000000,%eax
f010144f:	c1 e8 0c             	shr    $0xc,%eax
f0101452:	39 c3                	cmp    %eax,%ebx
f0101454:	73 16                	jae    f010146c <page_init+0xef>
			pages[i].pp_ref = 1;
f0101456:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f010145b:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f010145e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0101464:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010146a:	eb 28                	jmp    f0101494 <page_init+0x117>
f010146c:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
			pages[i].pp_ref = 0;
f0101473:	89 c2                	mov    %eax,%edx
f0101475:	03 15 90 1e 23 f0    	add    0xf0231e90,%edx
f010147b:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0101481:	8b 0d 40 12 23 f0    	mov    0xf0231240,%ecx
f0101487:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0101489:	03 05 90 1e 23 f0    	add    0xf0231e90,%eax
f010148f:	a3 40 12 23 f0       	mov    %eax,0xf0231240
	for (i = (EXTPHYSMEM / PGSIZE); i < npages; i++){
f0101494:	83 c3 01             	add    $0x1,%ebx
f0101497:	3b 1d 88 1e 23 f0    	cmp    0xf0231e88,%ebx
f010149d:	0f 82 76 ff ff ff    	jb     f0101419 <page_init+0x9c>
}
f01014a3:	83 c4 10             	add    $0x10,%esp
f01014a6:	5b                   	pop    %ebx
f01014a7:	5e                   	pop    %esi
f01014a8:	5d                   	pop    %ebp
f01014a9:	c3                   	ret    

f01014aa <page_alloc>:
{
f01014aa:	55                   	push   %ebp
f01014ab:	89 e5                	mov    %esp,%ebp
f01014ad:	53                   	push   %ebx
f01014ae:	83 ec 14             	sub    $0x14,%esp
	if (page_free_list == NULL){
f01014b1:	8b 1d 40 12 23 f0    	mov    0xf0231240,%ebx
f01014b7:	85 db                	test   %ebx,%ebx
f01014b9:	74 6f                	je     f010152a <page_alloc+0x80>
	page_free_list = new_page->pp_link;
f01014bb:	8b 03                	mov    (%ebx),%eax
f01014bd:	a3 40 12 23 f0       	mov    %eax,0xf0231240
	new_page->pp_link = NULL;
f01014c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return new_page;
f01014c8:	89 d8                	mov    %ebx,%eax
	if (alloc_flags & ALLOC_ZERO){
f01014ca:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01014ce:	74 5f                	je     f010152f <page_alloc+0x85>
	return (pp - pages) << PGSHIFT;
f01014d0:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f01014d6:	c1 f8 03             	sar    $0x3,%eax
f01014d9:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01014dc:	89 c2                	mov    %eax,%edx
f01014de:	c1 ea 0c             	shr    $0xc,%edx
f01014e1:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f01014e7:	72 20                	jb     f0101509 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014ed:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f01014f4:	f0 
f01014f5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01014fc:	00 
f01014fd:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f0101504:	e8 37 eb ff ff       	call   f0100040 <_panic>
		memset(page2kva(new_page), 0, PGSIZE);
f0101509:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101510:	00 
f0101511:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101518:	00 
	return (void *)(pa + KERNBASE);
f0101519:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010151e:	89 04 24             	mov    %eax,(%esp)
f0101521:	e8 91 50 00 00       	call   f01065b7 <memset>
	return new_page;
f0101526:	89 d8                	mov    %ebx,%eax
f0101528:	eb 05                	jmp    f010152f <page_alloc+0x85>
		return NULL;
f010152a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010152f:	83 c4 14             	add    $0x14,%esp
f0101532:	5b                   	pop    %ebx
f0101533:	5d                   	pop    %ebp
f0101534:	c3                   	ret    

f0101535 <page_free>:
{
f0101535:	55                   	push   %ebp
f0101536:	89 e5                	mov    %esp,%ebp
f0101538:	83 ec 18             	sub    $0x18,%esp
f010153b:	8b 45 08             	mov    0x8(%ebp),%eax
	if ( pp->pp_ref != 0 || pp->pp_link != NULL ){
f010153e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101543:	75 05                	jne    f010154a <page_free+0x15>
f0101545:	83 38 00             	cmpl   $0x0,(%eax)
f0101548:	74 1c                	je     f0101566 <page_free+0x31>
		panic("page_free: pp->pp_ref is non-zero or pp->pp_link is not NULL");
f010154a:	c7 44 24 08 20 80 10 	movl   $0xf0108020,0x8(%esp)
f0101551:	f0 
f0101552:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f0101559:	00 
f010155a:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101561:	e8 da ea ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f0101566:	8b 15 40 12 23 f0    	mov    0xf0231240,%edx
f010156c:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010156e:	a3 40 12 23 f0       	mov    %eax,0xf0231240
}
f0101573:	c9                   	leave  
f0101574:	c3                   	ret    

f0101575 <page_decref>:
{
f0101575:	55                   	push   %ebp
f0101576:	89 e5                	mov    %esp,%ebp
f0101578:	83 ec 18             	sub    $0x18,%esp
f010157b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010157e:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0101582:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101585:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101589:	66 85 d2             	test   %dx,%dx
f010158c:	75 08                	jne    f0101596 <page_decref+0x21>
		page_free(pp);
f010158e:	89 04 24             	mov    %eax,(%esp)
f0101591:	e8 9f ff ff ff       	call   f0101535 <page_free>
}
f0101596:	c9                   	leave  
f0101597:	c3                   	ret    

f0101598 <pgdir_walk>:
{
f0101598:	55                   	push   %ebp
f0101599:	89 e5                	mov    %esp,%ebp
f010159b:	56                   	push   %esi
f010159c:	53                   	push   %ebx
f010159d:	83 ec 10             	sub    $0x10,%esp
f01015a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pde_t pde = pgdir[PDX(va)];
f01015a3:	89 de                	mov    %ebx,%esi
f01015a5:	c1 ee 16             	shr    $0x16,%esi
f01015a8:	c1 e6 02             	shl    $0x2,%esi
f01015ab:	03 75 08             	add    0x8(%ebp),%esi
f01015ae:	8b 06                	mov    (%esi),%eax
	if (pde & PTE_P)
f01015b0:	a8 01                	test   $0x1,%al
f01015b2:	74 44                	je     f01015f8 <pgdir_walk+0x60>
		page_table = (pte_t *)KADDR(PTE_ADDR(pde));
f01015b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01015b9:	89 c2                	mov    %eax,%edx
f01015bb:	c1 ea 0c             	shr    $0xc,%edx
f01015be:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f01015c4:	72 20                	jb     f01015e6 <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015ca:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f01015d1:	f0 
f01015d2:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
f01015d9:	00 
f01015da:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01015e1:	e8 5a ea ff ff       	call   f0100040 <_panic>
		return &page_table[PTX(va)];
f01015e6:	c1 eb 0a             	shr    $0xa,%ebx
f01015e9:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01015ef:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01015f6:	eb 7e                	jmp    f0101676 <pgdir_walk+0xde>
		if (!create)
f01015f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01015fc:	74 6c                	je     f010166a <pgdir_walk+0xd2>
			struct PageInfo *pp_page_table = page_alloc(ALLOC_ZERO);
f01015fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101605:	e8 a0 fe ff ff       	call   f01014aa <page_alloc>
			if (!pp_page_table)
f010160a:	85 c0                	test   %eax,%eax
f010160c:	74 63                	je     f0101671 <pgdir_walk+0xd9>
			pp_page_table->pp_ref += 1;
f010160e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101613:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101619:	c1 f8 03             	sar    $0x3,%eax
f010161c:	c1 e0 0c             	shl    $0xc,%eax
			pgdir[PDX(va)] = page2pa(pp_page_table) | PTE_P | PTE_U | PTE_W;
f010161f:	89 c2                	mov    %eax,%edx
f0101621:	83 ca 07             	or     $0x7,%edx
f0101624:	89 16                	mov    %edx,(%esi)
			page_table = (pte_t *)KADDR(PTE_ADDR(pde));
f0101626:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010162b:	89 c2                	mov    %eax,%edx
f010162d:	c1 ea 0c             	shr    $0xc,%edx
f0101630:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101636:	72 20                	jb     f0101658 <pgdir_walk+0xc0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101638:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010163c:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0101643:	f0 
f0101644:	c7 44 24 04 f3 01 00 	movl   $0x1f3,0x4(%esp)
f010164b:	00 
f010164c:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101653:	e8 e8 e9 ff ff       	call   f0100040 <_panic>
			return &page_table[PTX(va)];
f0101658:	c1 eb 0a             	shr    $0xa,%ebx
f010165b:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101661:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101668:	eb 0c                	jmp    f0101676 <pgdir_walk+0xde>
			return NULL;
f010166a:	b8 00 00 00 00       	mov    $0x0,%eax
f010166f:	eb 05                	jmp    f0101676 <pgdir_walk+0xde>
				return NULL;
f0101671:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101676:	83 c4 10             	add    $0x10,%esp
f0101679:	5b                   	pop    %ebx
f010167a:	5e                   	pop    %esi
f010167b:	5d                   	pop    %ebp
f010167c:	c3                   	ret    

f010167d <boot_map_region>:
{
f010167d:	55                   	push   %ebp
f010167e:	89 e5                	mov    %esp,%ebp
f0101680:	57                   	push   %edi
f0101681:	56                   	push   %esi
f0101682:	53                   	push   %ebx
f0101683:	83 ec 2c             	sub    $0x2c,%esp
f0101686:	89 c7                	mov    %eax,%edi
f0101688:	8b 45 08             	mov    0x8(%ebp),%eax
	for (size_t i = 0; i < size / PGSIZE; i++){
f010168b:	c1 e9 0c             	shr    $0xc,%ecx
f010168e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101691:	89 c3                	mov    %eax,%ebx
f0101693:	be 00 00 00 00       	mov    $0x0,%esi
f0101698:	29 c2                	sub    %eax,%edx
f010169a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		*p_pte = PTE_ADDR(pa) | PTE_P | perm;
f010169d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016a0:	83 c8 01             	or     $0x1,%eax
f01016a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (size_t i = 0; i < size / PGSIZE; i++){
f01016a6:	eb 4f                	jmp    f01016f7 <boot_map_region+0x7a>
		pte_t *p_pte = pgdir_walk(pgdir, (void *) va, 1);
f01016a8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01016af:	00 
f01016b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01016b3:	01 d8                	add    %ebx,%eax
f01016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016b9:	89 3c 24             	mov    %edi,(%esp)
f01016bc:	e8 d7 fe ff ff       	call   f0101598 <pgdir_walk>
		if (!p_pte) 
f01016c1:	85 c0                	test   %eax,%eax
f01016c3:	75 1c                	jne    f01016e1 <boot_map_region+0x64>
			panic("boot_map_region: No p_pte");
f01016c5:	c7 44 24 08 c2 7c 10 	movl   $0xf0107cc2,0x8(%esp)
f01016cc:	f0 
f01016cd:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
f01016d4:	00 
f01016d5:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01016dc:	e8 5f e9 ff ff       	call   f0100040 <_panic>
		*p_pte = PTE_ADDR(pa) | PTE_P | perm;
f01016e1:	89 da                	mov    %ebx,%edx
f01016e3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01016e9:	0b 55 dc             	or     -0x24(%ebp),%edx
f01016ec:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f01016ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (size_t i = 0; i < size / PGSIZE; i++){
f01016f4:	83 c6 01             	add    $0x1,%esi
f01016f7:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01016fa:	75 ac                	jne    f01016a8 <boot_map_region+0x2b>
}
f01016fc:	83 c4 2c             	add    $0x2c,%esp
f01016ff:	5b                   	pop    %ebx
f0101700:	5e                   	pop    %esi
f0101701:	5f                   	pop    %edi
f0101702:	5d                   	pop    %ebp
f0101703:	c3                   	ret    

f0101704 <page_lookup>:
{
f0101704:	55                   	push   %ebp
f0101705:	89 e5                	mov    %esp,%ebp
f0101707:	53                   	push   %ebx
f0101708:	83 ec 14             	sub    $0x14,%esp
f010170b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *p_pte = pgdir_walk(pgdir, va, 0);
f010170e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101715:	00 
f0101716:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101719:	89 44 24 04          	mov    %eax,0x4(%esp)
f010171d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101720:	89 04 24             	mov    %eax,(%esp)
f0101723:	e8 70 fe ff ff       	call   f0101598 <pgdir_walk>
	if (!p_pte || (*p_pte & PTE_P)==0)
f0101728:	85 c0                	test   %eax,%eax
f010172a:	74 3f                	je     f010176b <page_lookup+0x67>
f010172c:	f6 00 01             	testb  $0x1,(%eax)
f010172f:	74 41                	je     f0101772 <page_lookup+0x6e>
	if (pte_store != NULL)
f0101731:	85 db                	test   %ebx,%ebx
f0101733:	74 02                	je     f0101737 <page_lookup+0x33>
		*pte_store = p_pte;	
f0101735:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*p_pte));
f0101737:	8b 00                	mov    (%eax),%eax
	if (PGNUM(pa) >= npages)
f0101739:	c1 e8 0c             	shr    $0xc,%eax
f010173c:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0101742:	72 1c                	jb     f0101760 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f0101744:	c7 44 24 08 60 80 10 	movl   $0xf0108060,0x8(%esp)
f010174b:	f0 
f010174c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101753:	00 
f0101754:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f010175b:	e8 e0 e8 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101760:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
f0101766:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0101769:	eb 0c                	jmp    f0101777 <page_lookup+0x73>
		return NULL;
f010176b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101770:	eb 05                	jmp    f0101777 <page_lookup+0x73>
f0101772:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101777:	83 c4 14             	add    $0x14,%esp
f010177a:	5b                   	pop    %ebx
f010177b:	5d                   	pop    %ebp
f010177c:	c3                   	ret    

f010177d <tlb_invalidate>:
{
f010177d:	55                   	push   %ebp
f010177e:	89 e5                	mov    %esp,%ebp
f0101780:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101783:	e8 81 54 00 00       	call   f0106c09 <cpunum>
f0101788:	6b c0 74             	imul   $0x74,%eax,%eax
f010178b:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0101792:	74 16                	je     f01017aa <tlb_invalidate+0x2d>
f0101794:	e8 70 54 00 00       	call   f0106c09 <cpunum>
f0101799:	6b c0 74             	imul   $0x74,%eax,%eax
f010179c:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01017a2:	8b 55 08             	mov    0x8(%ebp),%edx
f01017a5:	39 50 60             	cmp    %edx,0x60(%eax)
f01017a8:	75 06                	jne    f01017b0 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01017aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017ad:	0f 01 38             	invlpg (%eax)
}
f01017b0:	c9                   	leave  
f01017b1:	c3                   	ret    

f01017b2 <page_remove>:
{
f01017b2:	55                   	push   %ebp
f01017b3:	89 e5                	mov    %esp,%ebp
f01017b5:	56                   	push   %esi
f01017b6:	53                   	push   %ebx
f01017b7:	83 ec 20             	sub    $0x20,%esp
f01017ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01017bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pp = page_lookup(pgdir, va, &p_pte);
f01017c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01017c3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017c7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017cb:	89 1c 24             	mov    %ebx,(%esp)
f01017ce:	e8 31 ff ff ff       	call   f0101704 <page_lookup>
	if (pp){
f01017d3:	85 c0                	test   %eax,%eax
f01017d5:	74 1d                	je     f01017f4 <page_remove+0x42>
		page_decref(pp);
f01017d7:	89 04 24             	mov    %eax,(%esp)
f01017da:	e8 96 fd ff ff       	call   f0101575 <page_decref>
		*p_pte = 0;
f01017df:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01017e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f01017e8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017ec:	89 1c 24             	mov    %ebx,(%esp)
f01017ef:	e8 89 ff ff ff       	call   f010177d <tlb_invalidate>
}
f01017f4:	83 c4 20             	add    $0x20,%esp
f01017f7:	5b                   	pop    %ebx
f01017f8:	5e                   	pop    %esi
f01017f9:	5d                   	pop    %ebp
f01017fa:	c3                   	ret    

f01017fb <page_insert>:
{
f01017fb:	55                   	push   %ebp
f01017fc:	89 e5                	mov    %esp,%ebp
f01017fe:	57                   	push   %edi
f01017ff:	56                   	push   %esi
f0101800:	53                   	push   %ebx
f0101801:	83 ec 1c             	sub    $0x1c,%esp
f0101804:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101807:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *p_pte = pgdir_walk(pgdir, va, 1);
f010180a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101811:	00 
f0101812:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101816:	8b 45 08             	mov    0x8(%ebp),%eax
f0101819:	89 04 24             	mov    %eax,(%esp)
f010181c:	e8 77 fd ff ff       	call   f0101598 <pgdir_walk>
f0101821:	89 c3                	mov    %eax,%ebx
	if (!p_pte)
f0101823:	85 c0                	test   %eax,%eax
f0101825:	74 36                	je     f010185d <page_insert+0x62>
	pp->pp_ref++;
f0101827:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*p_pte & PTE_P)
f010182c:	f6 00 01             	testb  $0x1,(%eax)
f010182f:	74 0f                	je     f0101840 <page_insert+0x45>
		page_remove(pgdir, va);
f0101831:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101835:	8b 45 08             	mov    0x8(%ebp),%eax
f0101838:	89 04 24             	mov    %eax,(%esp)
f010183b:	e8 72 ff ff ff       	call   f01017b2 <page_remove>
	*p_pte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f0101840:	8b 45 14             	mov    0x14(%ebp),%eax
f0101843:	83 c8 01             	or     $0x1,%eax
	return (pp - pages) << PGSHIFT;
f0101846:	2b 35 90 1e 23 f0    	sub    0xf0231e90,%esi
f010184c:	c1 fe 03             	sar    $0x3,%esi
f010184f:	c1 e6 0c             	shl    $0xc,%esi
f0101852:	09 c6                	or     %eax,%esi
f0101854:	89 33                	mov    %esi,(%ebx)
	return 0;
f0101856:	b8 00 00 00 00       	mov    $0x0,%eax
f010185b:	eb 05                	jmp    f0101862 <page_insert+0x67>
		return -E_NO_MEM;
f010185d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f0101862:	83 c4 1c             	add    $0x1c,%esp
f0101865:	5b                   	pop    %ebx
f0101866:	5e                   	pop    %esi
f0101867:	5f                   	pop    %edi
f0101868:	5d                   	pop    %ebp
f0101869:	c3                   	ret    

f010186a <mmio_map_region>:
{
f010186a:	55                   	push   %ebp
f010186b:	89 e5                	mov    %esp,%ebp
f010186d:	57                   	push   %edi
f010186e:	56                   	push   %esi
f010186f:	53                   	push   %ebx
f0101870:	83 ec 1c             	sub    $0x1c,%esp
f0101873:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t pa_start = ROUNDDOWN( pa, PGSIZE );
f0101876:	89 c2                	mov    %eax,%edx
f0101878:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	uint32_t pa_end = ROUNDUP( pa + size, PGSIZE );
f010187e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101881:	8d 8c 08 ff 0f 00 00 	lea    0xfff(%eax,%ecx,1),%ecx
f0101888:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	uint32_t pa_offset = pa & 0xfff;
f010188e:	25 ff 0f 00 00       	and    $0xfff,%eax
	uint32_t va_start = base;
f0101893:	8b 1d 00 23 12 f0    	mov    0xf0122300,%ebx
	uint32_t new_base = va_start + pa_end - pa_start;
f0101899:	89 de                	mov    %ebx,%esi
f010189b:	29 d6                	sub    %edx,%esi
f010189d:	01 ce                	add    %ecx,%esi
	if (new_base >= MMIOLIM)
f010189f:	81 fe ff ff bf ef    	cmp    $0xefbfffff,%esi
f01018a5:	76 1c                	jbe    f01018c3 <mmio_map_region+0x59>
		panic("mmio_map_region: overflow");
f01018a7:	c7 44 24 08 dc 7c 10 	movl   $0xf0107cdc,0x8(%esp)
f01018ae:	f0 
f01018af:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f01018b6:	00 
f01018b7:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01018be:	e8 7d e7 ff ff       	call   f0100040 <_panic>
f01018c3:	89 c7                	mov    %eax,%edi
	boot_map_region(kern_pgdir, va_start, pa_end - pa_start, pa_start, PTE_PCD | PTE_PWT | PTE_W);
f01018c5:	29 d1                	sub    %edx,%ecx
f01018c7:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f01018ce:	00 
f01018cf:	89 14 24             	mov    %edx,(%esp)
f01018d2:	89 da                	mov    %ebx,%edx
f01018d4:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01018d9:	e8 9f fd ff ff       	call   f010167d <boot_map_region>
	base = new_base;
f01018de:	89 35 00 23 12 f0    	mov    %esi,0xf0122300
	return (void *)(va_start + pa_offset);
f01018e4:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
}
f01018e7:	83 c4 1c             	add    $0x1c,%esp
f01018ea:	5b                   	pop    %ebx
f01018eb:	5e                   	pop    %esi
f01018ec:	5f                   	pop    %edi
f01018ed:	5d                   	pop    %ebp
f01018ee:	c3                   	ret    

f01018ef <mem_init>:
{
f01018ef:	55                   	push   %ebp
f01018f0:	89 e5                	mov    %esp,%ebp
f01018f2:	57                   	push   %edi
f01018f3:	56                   	push   %esi
f01018f4:	53                   	push   %ebx
f01018f5:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01018f8:	b8 15 00 00 00       	mov    $0x15,%eax
f01018fd:	e8 7e f5 ff ff       	call   f0100e80 <nvram_read>
f0101902:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101904:	b8 17 00 00 00       	mov    $0x17,%eax
f0101909:	e8 72 f5 ff ff       	call   f0100e80 <nvram_read>
f010190e:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101910:	b8 34 00 00 00       	mov    $0x34,%eax
f0101915:	e8 66 f5 ff ff       	call   f0100e80 <nvram_read>
f010191a:	c1 e0 06             	shl    $0x6,%eax
f010191d:	89 c2                	mov    %eax,%edx
		totalmem = 16 * 1024 + ext16mem;
f010191f:	8d 80 00 40 00 00    	lea    0x4000(%eax),%eax
	if (ext16mem)
f0101925:	85 d2                	test   %edx,%edx
f0101927:	75 0b                	jne    f0101934 <mem_init+0x45>
		totalmem = 1 * 1024 + extmem;
f0101929:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010192f:	85 f6                	test   %esi,%esi
f0101931:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101934:	89 c2                	mov    %eax,%edx
f0101936:	c1 ea 02             	shr    $0x2,%edx
f0101939:	89 15 88 1e 23 f0    	mov    %edx,0xf0231e88
	npages_basemem = basemem / (PGSIZE / 1024);
f010193f:	89 da                	mov    %ebx,%edx
f0101941:	c1 ea 02             	shr    $0x2,%edx
f0101944:	89 15 44 12 23 f0    	mov    %edx,0xf0231244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010194a:	89 c2                	mov    %eax,%edx
f010194c:	29 da                	sub    %ebx,%edx
f010194e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101952:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101956:	89 44 24 04          	mov    %eax,0x4(%esp)
f010195a:	c7 04 24 80 80 10 f0 	movl   $0xf0108080,(%esp)
f0101961:	e8 ea 29 00 00       	call   f0104350 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101966:	b8 00 10 00 00       	mov    $0x1000,%eax
f010196b:	e8 3b f5 ff ff       	call   f0100eab <boot_alloc>
f0101970:	a3 8c 1e 23 f0       	mov    %eax,0xf0231e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101975:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010197c:	00 
f010197d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101984:	00 
f0101985:	89 04 24             	mov    %eax,(%esp)
f0101988:	e8 2a 4c 00 00       	call   f01065b7 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010198d:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101992:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101997:	77 20                	ja     f01019b9 <mem_init+0xca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101999:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010199d:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f01019a4:	f0 
f01019a5:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
f01019ac:	00 
f01019ad:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01019b4:	e8 87 e6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01019b9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01019bf:	83 ca 05             	or     $0x5,%edx
f01019c2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01019c8:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f01019cd:	c1 e0 03             	shl    $0x3,%eax
f01019d0:	e8 d6 f4 ff ff       	call   f0100eab <boot_alloc>
f01019d5:	a3 90 1e 23 f0       	mov    %eax,0xf0231e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01019da:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f01019e0:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01019e7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01019eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01019f2:	00 
f01019f3:	89 04 24             	mov    %eax,(%esp)
f01019f6:	e8 bc 4b 00 00       	call   f01065b7 <memset>
	envs = (struct Env *) boot_alloc(NENV*sizeof(struct Env));
f01019fb:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101a00:	e8 a6 f4 ff ff       	call   f0100eab <boot_alloc>
f0101a05:	a3 48 12 23 f0       	mov    %eax,0xf0231248
	memset(envs, 0, NENV * sizeof(struct Env));
f0101a0a:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f0101a11:	00 
f0101a12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101a19:	00 
f0101a1a:	89 04 24             	mov    %eax,(%esp)
f0101a1d:	e8 95 4b 00 00       	call   f01065b7 <memset>
	page_init();
f0101a22:	e8 56 f9 ff ff       	call   f010137d <page_init>
	check_page_free_list(1);
f0101a27:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a2c:	e8 a8 f5 ff ff       	call   f0100fd9 <check_page_free_list>
	if (!pages)
f0101a31:	83 3d 90 1e 23 f0 00 	cmpl   $0x0,0xf0231e90
f0101a38:	75 1c                	jne    f0101a56 <mem_init+0x167>
		panic("'pages' is a null pointer!");
f0101a3a:	c7 44 24 08 f6 7c 10 	movl   $0xf0107cf6,0x8(%esp)
f0101a41:	f0 
f0101a42:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101a49:	00 
f0101a4a:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101a51:	e8 ea e5 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a56:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0101a5b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101a60:	eb 05                	jmp    f0101a67 <mem_init+0x178>
		++nfree;
f0101a62:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a65:	8b 00                	mov    (%eax),%eax
f0101a67:	85 c0                	test   %eax,%eax
f0101a69:	75 f7                	jne    f0101a62 <mem_init+0x173>
	assert((pp0 = page_alloc(0)));
f0101a6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a72:	e8 33 fa ff ff       	call   f01014aa <page_alloc>
f0101a77:	89 c7                	mov    %eax,%edi
f0101a79:	85 c0                	test   %eax,%eax
f0101a7b:	75 24                	jne    f0101aa1 <mem_init+0x1b2>
f0101a7d:	c7 44 24 0c 11 7d 10 	movl   $0xf0107d11,0xc(%esp)
f0101a84:	f0 
f0101a85:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101a8c:	f0 
f0101a8d:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101a94:	00 
f0101a95:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101a9c:	e8 9f e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101aa1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aa8:	e8 fd f9 ff ff       	call   f01014aa <page_alloc>
f0101aad:	89 c6                	mov    %eax,%esi
f0101aaf:	85 c0                	test   %eax,%eax
f0101ab1:	75 24                	jne    f0101ad7 <mem_init+0x1e8>
f0101ab3:	c7 44 24 0c 27 7d 10 	movl   $0xf0107d27,0xc(%esp)
f0101aba:	f0 
f0101abb:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101ac2:	f0 
f0101ac3:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101aca:	00 
f0101acb:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101ad2:	e8 69 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ad7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ade:	e8 c7 f9 ff ff       	call   f01014aa <page_alloc>
f0101ae3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ae6:	85 c0                	test   %eax,%eax
f0101ae8:	75 24                	jne    f0101b0e <mem_init+0x21f>
f0101aea:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f0101af1:	f0 
f0101af2:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101af9:	f0 
f0101afa:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0101b01:	00 
f0101b02:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101b09:	e8 32 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101b0e:	39 f7                	cmp    %esi,%edi
f0101b10:	75 24                	jne    f0101b36 <mem_init+0x247>
f0101b12:	c7 44 24 0c 53 7d 10 	movl   $0xf0107d53,0xc(%esp)
f0101b19:	f0 
f0101b1a:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101b21:	f0 
f0101b22:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0101b29:	00 
f0101b2a:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101b31:	e8 0a e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b39:	39 c6                	cmp    %eax,%esi
f0101b3b:	74 04                	je     f0101b41 <mem_init+0x252>
f0101b3d:	39 c7                	cmp    %eax,%edi
f0101b3f:	75 24                	jne    f0101b65 <mem_init+0x276>
f0101b41:	c7 44 24 0c bc 80 10 	movl   $0xf01080bc,0xc(%esp)
f0101b48:	f0 
f0101b49:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101b50:	f0 
f0101b51:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101b58:	00 
f0101b59:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101b60:	e8 db e4 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101b65:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b6b:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f0101b70:	c1 e0 0c             	shl    $0xc,%eax
f0101b73:	89 f9                	mov    %edi,%ecx
f0101b75:	29 d1                	sub    %edx,%ecx
f0101b77:	c1 f9 03             	sar    $0x3,%ecx
f0101b7a:	c1 e1 0c             	shl    $0xc,%ecx
f0101b7d:	39 c1                	cmp    %eax,%ecx
f0101b7f:	72 24                	jb     f0101ba5 <mem_init+0x2b6>
f0101b81:	c7 44 24 0c 65 7d 10 	movl   $0xf0107d65,0xc(%esp)
f0101b88:	f0 
f0101b89:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101b90:	f0 
f0101b91:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101b98:	00 
f0101b99:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101ba0:	e8 9b e4 ff ff       	call   f0100040 <_panic>
f0101ba5:	89 f1                	mov    %esi,%ecx
f0101ba7:	29 d1                	sub    %edx,%ecx
f0101ba9:	c1 f9 03             	sar    $0x3,%ecx
f0101bac:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101baf:	39 c8                	cmp    %ecx,%eax
f0101bb1:	77 24                	ja     f0101bd7 <mem_init+0x2e8>
f0101bb3:	c7 44 24 0c 82 7d 10 	movl   $0xf0107d82,0xc(%esp)
f0101bba:	f0 
f0101bbb:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101bc2:	f0 
f0101bc3:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0101bca:	00 
f0101bcb:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101bd2:	e8 69 e4 ff ff       	call   f0100040 <_panic>
f0101bd7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bda:	29 d1                	sub    %edx,%ecx
f0101bdc:	89 ca                	mov    %ecx,%edx
f0101bde:	c1 fa 03             	sar    $0x3,%edx
f0101be1:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101be4:	39 d0                	cmp    %edx,%eax
f0101be6:	77 24                	ja     f0101c0c <mem_init+0x31d>
f0101be8:	c7 44 24 0c 9f 7d 10 	movl   $0xf0107d9f,0xc(%esp)
f0101bef:	f0 
f0101bf0:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101bf7:	f0 
f0101bf8:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0101bff:	00 
f0101c00:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101c07:	e8 34 e4 ff ff       	call   f0100040 <_panic>
	fl = page_free_list;
f0101c0c:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0101c11:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101c14:	c7 05 40 12 23 f0 00 	movl   $0x0,0xf0231240
f0101c1b:	00 00 00 
	assert(!page_alloc(0));
f0101c1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c25:	e8 80 f8 ff ff       	call   f01014aa <page_alloc>
f0101c2a:	85 c0                	test   %eax,%eax
f0101c2c:	74 24                	je     f0101c52 <mem_init+0x363>
f0101c2e:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f0101c35:	f0 
f0101c36:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101c3d:	f0 
f0101c3e:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101c45:	00 
f0101c46:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101c4d:	e8 ee e3 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0101c52:	89 3c 24             	mov    %edi,(%esp)
f0101c55:	e8 db f8 ff ff       	call   f0101535 <page_free>
	page_free(pp1);
f0101c5a:	89 34 24             	mov    %esi,(%esp)
f0101c5d:	e8 d3 f8 ff ff       	call   f0101535 <page_free>
	page_free(pp2);
f0101c62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c65:	89 04 24             	mov    %eax,(%esp)
f0101c68:	e8 c8 f8 ff ff       	call   f0101535 <page_free>
	assert((pp0 = page_alloc(0)));
f0101c6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c74:	e8 31 f8 ff ff       	call   f01014aa <page_alloc>
f0101c79:	89 c6                	mov    %eax,%esi
f0101c7b:	85 c0                	test   %eax,%eax
f0101c7d:	75 24                	jne    f0101ca3 <mem_init+0x3b4>
f0101c7f:	c7 44 24 0c 11 7d 10 	movl   $0xf0107d11,0xc(%esp)
f0101c86:	f0 
f0101c87:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101c8e:	f0 
f0101c8f:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0101c96:	00 
f0101c97:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101c9e:	e8 9d e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ca3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101caa:	e8 fb f7 ff ff       	call   f01014aa <page_alloc>
f0101caf:	89 c7                	mov    %eax,%edi
f0101cb1:	85 c0                	test   %eax,%eax
f0101cb3:	75 24                	jne    f0101cd9 <mem_init+0x3ea>
f0101cb5:	c7 44 24 0c 27 7d 10 	movl   $0xf0107d27,0xc(%esp)
f0101cbc:	f0 
f0101cbd:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101cc4:	f0 
f0101cc5:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101ccc:	00 
f0101ccd:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101cd4:	e8 67 e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101cd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ce0:	e8 c5 f7 ff ff       	call   f01014aa <page_alloc>
f0101ce5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ce8:	85 c0                	test   %eax,%eax
f0101cea:	75 24                	jne    f0101d10 <mem_init+0x421>
f0101cec:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f0101cf3:	f0 
f0101cf4:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101cfb:	f0 
f0101cfc:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101d03:	00 
f0101d04:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101d0b:	e8 30 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101d10:	39 fe                	cmp    %edi,%esi
f0101d12:	75 24                	jne    f0101d38 <mem_init+0x449>
f0101d14:	c7 44 24 0c 53 7d 10 	movl   $0xf0107d53,0xc(%esp)
f0101d1b:	f0 
f0101d1c:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101d23:	f0 
f0101d24:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101d2b:	00 
f0101d2c:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101d33:	e8 08 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d3b:	39 c7                	cmp    %eax,%edi
f0101d3d:	74 04                	je     f0101d43 <mem_init+0x454>
f0101d3f:	39 c6                	cmp    %eax,%esi
f0101d41:	75 24                	jne    f0101d67 <mem_init+0x478>
f0101d43:	c7 44 24 0c bc 80 10 	movl   $0xf01080bc,0xc(%esp)
f0101d4a:	f0 
f0101d4b:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101d52:	f0 
f0101d53:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101d5a:	00 
f0101d5b:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101d62:	e8 d9 e2 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101d67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d6e:	e8 37 f7 ff ff       	call   f01014aa <page_alloc>
f0101d73:	85 c0                	test   %eax,%eax
f0101d75:	74 24                	je     f0101d9b <mem_init+0x4ac>
f0101d77:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f0101d7e:	f0 
f0101d7f:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101d86:	f0 
f0101d87:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101d8e:	00 
f0101d8f:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101d96:	e8 a5 e2 ff ff       	call   f0100040 <_panic>
f0101d9b:	89 f0                	mov    %esi,%eax
f0101d9d:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101da3:	c1 f8 03             	sar    $0x3,%eax
f0101da6:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101da9:	89 c2                	mov    %eax,%edx
f0101dab:	c1 ea 0c             	shr    $0xc,%edx
f0101dae:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101db4:	72 20                	jb     f0101dd6 <mem_init+0x4e7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101db6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101dba:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0101dc1:	f0 
f0101dc2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101dc9:	00 
f0101dca:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f0101dd1:	e8 6a e2 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
f0101dd6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ddd:	00 
f0101dde:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101de5:	00 
	return (void *)(pa + KERNBASE);
f0101de6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101deb:	89 04 24             	mov    %eax,(%esp)
f0101dee:	e8 c4 47 00 00       	call   f01065b7 <memset>
	page_free(pp0);
f0101df3:	89 34 24             	mov    %esi,(%esp)
f0101df6:	e8 3a f7 ff ff       	call   f0101535 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101dfb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101e02:	e8 a3 f6 ff ff       	call   f01014aa <page_alloc>
f0101e07:	85 c0                	test   %eax,%eax
f0101e09:	75 24                	jne    f0101e2f <mem_init+0x540>
f0101e0b:	c7 44 24 0c cb 7d 10 	movl   $0xf0107dcb,0xc(%esp)
f0101e12:	f0 
f0101e13:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101e1a:	f0 
f0101e1b:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101e22:	00 
f0101e23:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101e2a:	e8 11 e2 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101e2f:	39 c6                	cmp    %eax,%esi
f0101e31:	74 24                	je     f0101e57 <mem_init+0x568>
f0101e33:	c7 44 24 0c e9 7d 10 	movl   $0xf0107de9,0xc(%esp)
f0101e3a:	f0 
f0101e3b:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101e42:	f0 
f0101e43:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101e4a:	00 
f0101e4b:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101e52:	e8 e9 e1 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101e57:	89 f0                	mov    %esi,%eax
f0101e59:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0101e5f:	c1 f8 03             	sar    $0x3,%eax
f0101e62:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e65:	89 c2                	mov    %eax,%edx
f0101e67:	c1 ea 0c             	shr    $0xc,%edx
f0101e6a:	3b 15 88 1e 23 f0    	cmp    0xf0231e88,%edx
f0101e70:	72 20                	jb     f0101e92 <mem_init+0x5a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e72:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e76:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0101e7d:	f0 
f0101e7e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101e85:	00 
f0101e86:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f0101e8d:	e8 ae e1 ff ff       	call   f0100040 <_panic>
f0101e92:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101e98:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
		assert(c[i] == 0);
f0101e9e:	80 38 00             	cmpb   $0x0,(%eax)
f0101ea1:	74 24                	je     f0101ec7 <mem_init+0x5d8>
f0101ea3:	c7 44 24 0c f9 7d 10 	movl   $0xf0107df9,0xc(%esp)
f0101eaa:	f0 
f0101eab:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101eb2:	f0 
f0101eb3:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101eba:	00 
f0101ebb:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101ec2:	e8 79 e1 ff ff       	call   f0100040 <_panic>
f0101ec7:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101eca:	39 d0                	cmp    %edx,%eax
f0101ecc:	75 d0                	jne    f0101e9e <mem_init+0x5af>
	page_free_list = fl;
f0101ece:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ed1:	a3 40 12 23 f0       	mov    %eax,0xf0231240
	page_free(pp0);
f0101ed6:	89 34 24             	mov    %esi,(%esp)
f0101ed9:	e8 57 f6 ff ff       	call   f0101535 <page_free>
	page_free(pp1);
f0101ede:	89 3c 24             	mov    %edi,(%esp)
f0101ee1:	e8 4f f6 ff ff       	call   f0101535 <page_free>
	page_free(pp2);
f0101ee6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ee9:	89 04 24             	mov    %eax,(%esp)
f0101eec:	e8 44 f6 ff ff       	call   f0101535 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ef1:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0101ef6:	eb 05                	jmp    f0101efd <mem_init+0x60e>
		--nfree;
f0101ef8:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101efb:	8b 00                	mov    (%eax),%eax
f0101efd:	85 c0                	test   %eax,%eax
f0101eff:	75 f7                	jne    f0101ef8 <mem_init+0x609>
	assert(nfree == 0);
f0101f01:	85 db                	test   %ebx,%ebx
f0101f03:	74 24                	je     f0101f29 <mem_init+0x63a>
f0101f05:	c7 44 24 0c 03 7e 10 	movl   $0xf0107e03,0xc(%esp)
f0101f0c:	f0 
f0101f0d:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101f14:	f0 
f0101f15:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101f1c:	00 
f0101f1d:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101f24:	e8 17 e1 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_alloc() succeeded!\n");
f0101f29:	c7 04 24 dc 80 10 f0 	movl   $0xf01080dc,(%esp)
f0101f30:	e8 1b 24 00 00       	call   f0104350 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101f35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f3c:	e8 69 f5 ff ff       	call   f01014aa <page_alloc>
f0101f41:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f44:	85 c0                	test   %eax,%eax
f0101f46:	75 24                	jne    f0101f6c <mem_init+0x67d>
f0101f48:	c7 44 24 0c 11 7d 10 	movl   $0xf0107d11,0xc(%esp)
f0101f4f:	f0 
f0101f50:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101f57:	f0 
f0101f58:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f0101f5f:	00 
f0101f60:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101f67:	e8 d4 e0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f73:	e8 32 f5 ff ff       	call   f01014aa <page_alloc>
f0101f78:	89 c3                	mov    %eax,%ebx
f0101f7a:	85 c0                	test   %eax,%eax
f0101f7c:	75 24                	jne    f0101fa2 <mem_init+0x6b3>
f0101f7e:	c7 44 24 0c 27 7d 10 	movl   $0xf0107d27,0xc(%esp)
f0101f85:	f0 
f0101f86:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101f8d:	f0 
f0101f8e:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0101f95:	00 
f0101f96:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101f9d:	e8 9e e0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101fa2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fa9:	e8 fc f4 ff ff       	call   f01014aa <page_alloc>
f0101fae:	89 c6                	mov    %eax,%esi
f0101fb0:	85 c0                	test   %eax,%eax
f0101fb2:	75 24                	jne    f0101fd8 <mem_init+0x6e9>
f0101fb4:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f0101fbb:	f0 
f0101fbc:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101fc3:	f0 
f0101fc4:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0101fcb:	00 
f0101fcc:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101fd3:	e8 68 e0 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101fd8:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101fdb:	75 24                	jne    f0102001 <mem_init+0x712>
f0101fdd:	c7 44 24 0c 53 7d 10 	movl   $0xf0107d53,0xc(%esp)
f0101fe4:	f0 
f0101fe5:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0101fec:	f0 
f0101fed:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0101ff4:	00 
f0101ff5:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0101ffc:	e8 3f e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102001:	39 c3                	cmp    %eax,%ebx
f0102003:	74 05                	je     f010200a <mem_init+0x71b>
f0102005:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102008:	75 24                	jne    f010202e <mem_init+0x73f>
f010200a:	c7 44 24 0c bc 80 10 	movl   $0xf01080bc,0xc(%esp)
f0102011:	f0 
f0102012:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102019:	f0 
f010201a:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102021:	00 
f0102022:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102029:	e8 12 e0 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010202e:	a1 40 12 23 f0       	mov    0xf0231240,%eax
f0102033:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0102036:	c7 05 40 12 23 f0 00 	movl   $0x0,0xf0231240
f010203d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102040:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102047:	e8 5e f4 ff ff       	call   f01014aa <page_alloc>
f010204c:	85 c0                	test   %eax,%eax
f010204e:	74 24                	je     f0102074 <mem_init+0x785>
f0102050:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f0102057:	f0 
f0102058:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010205f:	f0 
f0102060:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102067:	00 
f0102068:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010206f:	e8 cc df ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102074:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102077:	89 44 24 08          	mov    %eax,0x8(%esp)
f010207b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102082:	00 
f0102083:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102088:	89 04 24             	mov    %eax,(%esp)
f010208b:	e8 74 f6 ff ff       	call   f0101704 <page_lookup>
f0102090:	85 c0                	test   %eax,%eax
f0102092:	74 24                	je     f01020b8 <mem_init+0x7c9>
f0102094:	c7 44 24 0c fc 80 10 	movl   $0xf01080fc,0xc(%esp)
f010209b:	f0 
f010209c:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01020a3:	f0 
f01020a4:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f01020ab:	00 
f01020ac:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01020b3:	e8 88 df ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01020b8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020bf:	00 
f01020c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020c7:	00 
f01020c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01020cc:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01020d1:	89 04 24             	mov    %eax,(%esp)
f01020d4:	e8 22 f7 ff ff       	call   f01017fb <page_insert>
f01020d9:	85 c0                	test   %eax,%eax
f01020db:	78 24                	js     f0102101 <mem_init+0x812>
f01020dd:	c7 44 24 0c 34 81 10 	movl   $0xf0108134,0xc(%esp)
f01020e4:	f0 
f01020e5:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01020ec:	f0 
f01020ed:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01020f4:	00 
f01020f5:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01020fc:	e8 3f df ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102101:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102104:	89 04 24             	mov    %eax,(%esp)
f0102107:	e8 29 f4 ff ff       	call   f0101535 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010210c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102113:	00 
f0102114:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010211b:	00 
f010211c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102120:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102125:	89 04 24             	mov    %eax,(%esp)
f0102128:	e8 ce f6 ff ff       	call   f01017fb <page_insert>
f010212d:	85 c0                	test   %eax,%eax
f010212f:	74 24                	je     f0102155 <mem_init+0x866>
f0102131:	c7 44 24 0c 64 81 10 	movl   $0xf0108164,0xc(%esp)
f0102138:	f0 
f0102139:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102140:	f0 
f0102141:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f0102148:	00 
f0102149:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102150:	e8 eb de ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102155:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
	return (pp - pages) << PGSHIFT;
f010215b:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0102160:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102163:	8b 17                	mov    (%edi),%edx
f0102165:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010216b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010216e:	29 c1                	sub    %eax,%ecx
f0102170:	89 c8                	mov    %ecx,%eax
f0102172:	c1 f8 03             	sar    $0x3,%eax
f0102175:	c1 e0 0c             	shl    $0xc,%eax
f0102178:	39 c2                	cmp    %eax,%edx
f010217a:	74 24                	je     f01021a0 <mem_init+0x8b1>
f010217c:	c7 44 24 0c 94 81 10 	movl   $0xf0108194,0xc(%esp)
f0102183:	f0 
f0102184:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010218b:	f0 
f010218c:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102193:	00 
f0102194:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010219b:	e8 a0 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01021a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01021a5:	89 f8                	mov    %edi,%eax
f01021a7:	e8 be ed ff ff       	call   f0100f6a <check_va2pa>
f01021ac:	89 da                	mov    %ebx,%edx
f01021ae:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01021b1:	c1 fa 03             	sar    $0x3,%edx
f01021b4:	c1 e2 0c             	shl    $0xc,%edx
f01021b7:	39 d0                	cmp    %edx,%eax
f01021b9:	74 24                	je     f01021df <mem_init+0x8f0>
f01021bb:	c7 44 24 0c bc 81 10 	movl   $0xf01081bc,0xc(%esp)
f01021c2:	f0 
f01021c3:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01021ca:	f0 
f01021cb:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01021d2:	00 
f01021d3:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01021da:	e8 61 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01021df:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01021e4:	74 24                	je     f010220a <mem_init+0x91b>
f01021e6:	c7 44 24 0c 0e 7e 10 	movl   $0xf0107e0e,0xc(%esp)
f01021ed:	f0 
f01021ee:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01021f5:	f0 
f01021f6:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f01021fd:	00 
f01021fe:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102205:	e8 36 de ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f010220a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010220d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102212:	74 24                	je     f0102238 <mem_init+0x949>
f0102214:	c7 44 24 0c 1f 7e 10 	movl   $0xf0107e1f,0xc(%esp)
f010221b:	f0 
f010221c:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102223:	f0 
f0102224:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f010222b:	00 
f010222c:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102233:	e8 08 de ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102238:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010223f:	00 
f0102240:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102247:	00 
f0102248:	89 74 24 04          	mov    %esi,0x4(%esp)
f010224c:	89 3c 24             	mov    %edi,(%esp)
f010224f:	e8 a7 f5 ff ff       	call   f01017fb <page_insert>
f0102254:	85 c0                	test   %eax,%eax
f0102256:	74 24                	je     f010227c <mem_init+0x98d>
f0102258:	c7 44 24 0c ec 81 10 	movl   $0xf01081ec,0xc(%esp)
f010225f:	f0 
f0102260:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102267:	f0 
f0102268:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f010226f:	00 
f0102270:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102277:	e8 c4 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010227c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102281:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102286:	e8 df ec ff ff       	call   f0100f6a <check_va2pa>
f010228b:	89 f2                	mov    %esi,%edx
f010228d:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0102293:	c1 fa 03             	sar    $0x3,%edx
f0102296:	c1 e2 0c             	shl    $0xc,%edx
f0102299:	39 d0                	cmp    %edx,%eax
f010229b:	74 24                	je     f01022c1 <mem_init+0x9d2>
f010229d:	c7 44 24 0c 28 82 10 	movl   $0xf0108228,0xc(%esp)
f01022a4:	f0 
f01022a5:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01022ac:	f0 
f01022ad:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f01022b4:	00 
f01022b5:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01022bc:	e8 7f dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01022c1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022c6:	74 24                	je     f01022ec <mem_init+0x9fd>
f01022c8:	c7 44 24 0c 30 7e 10 	movl   $0xf0107e30,0xc(%esp)
f01022cf:	f0 
f01022d0:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01022d7:	f0 
f01022d8:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01022df:	00 
f01022e0:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01022e7:	e8 54 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01022ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022f3:	e8 b2 f1 ff ff       	call   f01014aa <page_alloc>
f01022f8:	85 c0                	test   %eax,%eax
f01022fa:	74 24                	je     f0102320 <mem_init+0xa31>
f01022fc:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f0102303:	f0 
f0102304:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010230b:	f0 
f010230c:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0102313:	00 
f0102314:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010231b:	e8 20 dd ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102320:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102327:	00 
f0102328:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010232f:	00 
f0102330:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102334:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102339:	89 04 24             	mov    %eax,(%esp)
f010233c:	e8 ba f4 ff ff       	call   f01017fb <page_insert>
f0102341:	85 c0                	test   %eax,%eax
f0102343:	74 24                	je     f0102369 <mem_init+0xa7a>
f0102345:	c7 44 24 0c ec 81 10 	movl   $0xf01081ec,0xc(%esp)
f010234c:	f0 
f010234d:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102354:	f0 
f0102355:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f010235c:	00 
f010235d:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102364:	e8 d7 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102369:	ba 00 10 00 00       	mov    $0x1000,%edx
f010236e:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102373:	e8 f2 eb ff ff       	call   f0100f6a <check_va2pa>
f0102378:	89 f2                	mov    %esi,%edx
f010237a:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0102380:	c1 fa 03             	sar    $0x3,%edx
f0102383:	c1 e2 0c             	shl    $0xc,%edx
f0102386:	39 d0                	cmp    %edx,%eax
f0102388:	74 24                	je     f01023ae <mem_init+0xabf>
f010238a:	c7 44 24 0c 28 82 10 	movl   $0xf0108228,0xc(%esp)
f0102391:	f0 
f0102392:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102399:	f0 
f010239a:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f01023a1:	00 
f01023a2:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01023a9:	e8 92 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01023ae:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01023b3:	74 24                	je     f01023d9 <mem_init+0xaea>
f01023b5:	c7 44 24 0c 30 7e 10 	movl   $0xf0107e30,0xc(%esp)
f01023bc:	f0 
f01023bd:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01023c4:	f0 
f01023c5:	c7 44 24 04 1b 04 00 	movl   $0x41b,0x4(%esp)
f01023cc:	00 
f01023cd:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01023d4:	e8 67 dc ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01023d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023e0:	e8 c5 f0 ff ff       	call   f01014aa <page_alloc>
f01023e5:	85 c0                	test   %eax,%eax
f01023e7:	74 24                	je     f010240d <mem_init+0xb1e>
f01023e9:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f01023f0:	f0 
f01023f1:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01023f8:	f0 
f01023f9:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0102400:	00 
f0102401:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102408:	e8 33 dc ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010240d:	8b 15 8c 1e 23 f0    	mov    0xf0231e8c,%edx
f0102413:	8b 02                	mov    (%edx),%eax
f0102415:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010241a:	89 c1                	mov    %eax,%ecx
f010241c:	c1 e9 0c             	shr    $0xc,%ecx
f010241f:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0102425:	72 20                	jb     f0102447 <mem_init+0xb58>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102427:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010242b:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0102432:	f0 
f0102433:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f010243a:	00 
f010243b:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102442:	e8 f9 db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102447:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010244c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010244f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102456:	00 
f0102457:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010245e:	00 
f010245f:	89 14 24             	mov    %edx,(%esp)
f0102462:	e8 31 f1 ff ff       	call   f0101598 <pgdir_walk>
f0102467:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010246a:	8d 51 04             	lea    0x4(%ecx),%edx
f010246d:	39 d0                	cmp    %edx,%eax
f010246f:	74 24                	je     f0102495 <mem_init+0xba6>
f0102471:	c7 44 24 0c 58 82 10 	movl   $0xf0108258,0xc(%esp)
f0102478:	f0 
f0102479:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102480:	f0 
f0102481:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f0102488:	00 
f0102489:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102490:	e8 ab db ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102495:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010249c:	00 
f010249d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024a4:	00 
f01024a5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024a9:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01024ae:	89 04 24             	mov    %eax,(%esp)
f01024b1:	e8 45 f3 ff ff       	call   f01017fb <page_insert>
f01024b6:	85 c0                	test   %eax,%eax
f01024b8:	74 24                	je     f01024de <mem_init+0xbef>
f01024ba:	c7 44 24 0c 98 82 10 	movl   $0xf0108298,0xc(%esp)
f01024c1:	f0 
f01024c2:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01024c9:	f0 
f01024ca:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f01024d1:	00 
f01024d2:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01024d9:	e8 62 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024de:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f01024e4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024e9:	89 f8                	mov    %edi,%eax
f01024eb:	e8 7a ea ff ff       	call   f0100f6a <check_va2pa>
	return (pp - pages) << PGSHIFT;
f01024f0:	89 f2                	mov    %esi,%edx
f01024f2:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f01024f8:	c1 fa 03             	sar    $0x3,%edx
f01024fb:	c1 e2 0c             	shl    $0xc,%edx
f01024fe:	39 d0                	cmp    %edx,%eax
f0102500:	74 24                	je     f0102526 <mem_init+0xc37>
f0102502:	c7 44 24 0c 28 82 10 	movl   $0xf0108228,0xc(%esp)
f0102509:	f0 
f010250a:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102511:	f0 
f0102512:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f0102519:	00 
f010251a:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102521:	e8 1a db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102526:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010252b:	74 24                	je     f0102551 <mem_init+0xc62>
f010252d:	c7 44 24 0c 30 7e 10 	movl   $0xf0107e30,0xc(%esp)
f0102534:	f0 
f0102535:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010253c:	f0 
f010253d:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f0102544:	00 
f0102545:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010254c:	e8 ef da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102551:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102558:	00 
f0102559:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102560:	00 
f0102561:	89 3c 24             	mov    %edi,(%esp)
f0102564:	e8 2f f0 ff ff       	call   f0101598 <pgdir_walk>
f0102569:	f6 00 04             	testb  $0x4,(%eax)
f010256c:	75 24                	jne    f0102592 <mem_init+0xca3>
f010256e:	c7 44 24 0c d8 82 10 	movl   $0xf01082d8,0xc(%esp)
f0102575:	f0 
f0102576:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010257d:	f0 
f010257e:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0102585:	00 
f0102586:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010258d:	e8 ae da ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102592:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102597:	f6 00 04             	testb  $0x4,(%eax)
f010259a:	75 24                	jne    f01025c0 <mem_init+0xcd1>
f010259c:	c7 44 24 0c 41 7e 10 	movl   $0xf0107e41,0xc(%esp)
f01025a3:	f0 
f01025a4:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01025ab:	f0 
f01025ac:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f01025b3:	00 
f01025b4:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01025bb:	e8 80 da ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025c0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025c7:	00 
f01025c8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025cf:	00 
f01025d0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01025d4:	89 04 24             	mov    %eax,(%esp)
f01025d7:	e8 1f f2 ff ff       	call   f01017fb <page_insert>
f01025dc:	85 c0                	test   %eax,%eax
f01025de:	74 24                	je     f0102604 <mem_init+0xd15>
f01025e0:	c7 44 24 0c ec 81 10 	movl   $0xf01081ec,0xc(%esp)
f01025e7:	f0 
f01025e8:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01025ef:	f0 
f01025f0:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f01025f7:	00 
f01025f8:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01025ff:	e8 3c da ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102604:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010260b:	00 
f010260c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102613:	00 
f0102614:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102619:	89 04 24             	mov    %eax,(%esp)
f010261c:	e8 77 ef ff ff       	call   f0101598 <pgdir_walk>
f0102621:	f6 00 02             	testb  $0x2,(%eax)
f0102624:	75 24                	jne    f010264a <mem_init+0xd5b>
f0102626:	c7 44 24 0c 0c 83 10 	movl   $0xf010830c,0xc(%esp)
f010262d:	f0 
f010262e:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102635:	f0 
f0102636:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f010263d:	00 
f010263e:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102645:	e8 f6 d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010264a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102651:	00 
f0102652:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102659:	00 
f010265a:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010265f:	89 04 24             	mov    %eax,(%esp)
f0102662:	e8 31 ef ff ff       	call   f0101598 <pgdir_walk>
f0102667:	f6 00 04             	testb  $0x4,(%eax)
f010266a:	74 24                	je     f0102690 <mem_init+0xda1>
f010266c:	c7 44 24 0c 40 83 10 	movl   $0xf0108340,0xc(%esp)
f0102673:	f0 
f0102674:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010267b:	f0 
f010267c:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f0102683:	00 
f0102684:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010268b:	e8 b0 d9 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102690:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102697:	00 
f0102698:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010269f:	00 
f01026a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01026a7:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01026ac:	89 04 24             	mov    %eax,(%esp)
f01026af:	e8 47 f1 ff ff       	call   f01017fb <page_insert>
f01026b4:	85 c0                	test   %eax,%eax
f01026b6:	78 24                	js     f01026dc <mem_init+0xded>
f01026b8:	c7 44 24 0c 78 83 10 	movl   $0xf0108378,0xc(%esp)
f01026bf:	f0 
f01026c0:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01026c7:	f0 
f01026c8:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f01026cf:	00 
f01026d0:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01026d7:	e8 64 d9 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01026dc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01026e3:	00 
f01026e4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026eb:	00 
f01026ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01026f0:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01026f5:	89 04 24             	mov    %eax,(%esp)
f01026f8:	e8 fe f0 ff ff       	call   f01017fb <page_insert>
f01026fd:	85 c0                	test   %eax,%eax
f01026ff:	74 24                	je     f0102725 <mem_init+0xe36>
f0102701:	c7 44 24 0c b0 83 10 	movl   $0xf01083b0,0xc(%esp)
f0102708:	f0 
f0102709:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102710:	f0 
f0102711:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102718:	00 
f0102719:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102720:	e8 1b d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102725:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010272c:	00 
f010272d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102734:	00 
f0102735:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010273a:	89 04 24             	mov    %eax,(%esp)
f010273d:	e8 56 ee ff ff       	call   f0101598 <pgdir_walk>
f0102742:	f6 00 04             	testb  $0x4,(%eax)
f0102745:	74 24                	je     f010276b <mem_init+0xe7c>
f0102747:	c7 44 24 0c 40 83 10 	movl   $0xf0108340,0xc(%esp)
f010274e:	f0 
f010274f:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102756:	f0 
f0102757:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f010275e:	00 
f010275f:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102766:	e8 d5 d8 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010276b:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0102771:	ba 00 00 00 00       	mov    $0x0,%edx
f0102776:	89 f8                	mov    %edi,%eax
f0102778:	e8 ed e7 ff ff       	call   f0100f6a <check_va2pa>
f010277d:	89 c1                	mov    %eax,%ecx
f010277f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102782:	89 d8                	mov    %ebx,%eax
f0102784:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f010278a:	c1 f8 03             	sar    $0x3,%eax
f010278d:	c1 e0 0c             	shl    $0xc,%eax
f0102790:	39 c1                	cmp    %eax,%ecx
f0102792:	74 24                	je     f01027b8 <mem_init+0xec9>
f0102794:	c7 44 24 0c ec 83 10 	movl   $0xf01083ec,0xc(%esp)
f010279b:	f0 
f010279c:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01027a3:	f0 
f01027a4:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f01027ab:	00 
f01027ac:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01027b3:	e8 88 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01027b8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01027bd:	89 f8                	mov    %edi,%eax
f01027bf:	e8 a6 e7 ff ff       	call   f0100f6a <check_va2pa>
f01027c4:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01027c7:	74 24                	je     f01027ed <mem_init+0xefe>
f01027c9:	c7 44 24 0c 18 84 10 	movl   $0xf0108418,0xc(%esp)
f01027d0:	f0 
f01027d1:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01027d8:	f0 
f01027d9:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f01027e0:	00 
f01027e1:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01027e8:	e8 53 d8 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01027ed:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01027f2:	74 24                	je     f0102818 <mem_init+0xf29>
f01027f4:	c7 44 24 0c 57 7e 10 	movl   $0xf0107e57,0xc(%esp)
f01027fb:	f0 
f01027fc:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102803:	f0 
f0102804:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f010280b:	00 
f010280c:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102813:	e8 28 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102818:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010281d:	74 24                	je     f0102843 <mem_init+0xf54>
f010281f:	c7 44 24 0c 68 7e 10 	movl   $0xf0107e68,0xc(%esp)
f0102826:	f0 
f0102827:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010282e:	f0 
f010282f:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102836:	00 
f0102837:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010283e:	e8 fd d7 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102843:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010284a:	e8 5b ec ff ff       	call   f01014aa <page_alloc>
f010284f:	85 c0                	test   %eax,%eax
f0102851:	74 04                	je     f0102857 <mem_init+0xf68>
f0102853:	39 c6                	cmp    %eax,%esi
f0102855:	74 24                	je     f010287b <mem_init+0xf8c>
f0102857:	c7 44 24 0c 48 84 10 	movl   $0xf0108448,0xc(%esp)
f010285e:	f0 
f010285f:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102866:	f0 
f0102867:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
f010286e:	00 
f010286f:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102876:	e8 c5 d7 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010287b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102882:	00 
f0102883:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102888:	89 04 24             	mov    %eax,(%esp)
f010288b:	e8 22 ef ff ff       	call   f01017b2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102890:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0102896:	ba 00 00 00 00       	mov    $0x0,%edx
f010289b:	89 f8                	mov    %edi,%eax
f010289d:	e8 c8 e6 ff ff       	call   f0100f6a <check_va2pa>
f01028a2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028a5:	74 24                	je     f01028cb <mem_init+0xfdc>
f01028a7:	c7 44 24 0c 6c 84 10 	movl   $0xf010846c,0xc(%esp)
f01028ae:	f0 
f01028af:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01028b6:	f0 
f01028b7:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f01028be:	00 
f01028bf:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01028c6:	e8 75 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01028cb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01028d0:	89 f8                	mov    %edi,%eax
f01028d2:	e8 93 e6 ff ff       	call   f0100f6a <check_va2pa>
f01028d7:	89 da                	mov    %ebx,%edx
f01028d9:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f01028df:	c1 fa 03             	sar    $0x3,%edx
f01028e2:	c1 e2 0c             	shl    $0xc,%edx
f01028e5:	39 d0                	cmp    %edx,%eax
f01028e7:	74 24                	je     f010290d <mem_init+0x101e>
f01028e9:	c7 44 24 0c 18 84 10 	movl   $0xf0108418,0xc(%esp)
f01028f0:	f0 
f01028f1:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01028f8:	f0 
f01028f9:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0102900:	00 
f0102901:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102908:	e8 33 d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010290d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102912:	74 24                	je     f0102938 <mem_init+0x1049>
f0102914:	c7 44 24 0c 0e 7e 10 	movl   $0xf0107e0e,0xc(%esp)
f010291b:	f0 
f010291c:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102923:	f0 
f0102924:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f010292b:	00 
f010292c:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102933:	e8 08 d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102938:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010293d:	74 24                	je     f0102963 <mem_init+0x1074>
f010293f:	c7 44 24 0c 68 7e 10 	movl   $0xf0107e68,0xc(%esp)
f0102946:	f0 
f0102947:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010294e:	f0 
f010294f:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f0102956:	00 
f0102957:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010295e:	e8 dd d6 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102963:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010296a:	00 
f010296b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102972:	00 
f0102973:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102977:	89 3c 24             	mov    %edi,(%esp)
f010297a:	e8 7c ee ff ff       	call   f01017fb <page_insert>
f010297f:	85 c0                	test   %eax,%eax
f0102981:	74 24                	je     f01029a7 <mem_init+0x10b8>
f0102983:	c7 44 24 0c 90 84 10 	movl   $0xf0108490,0xc(%esp)
f010298a:	f0 
f010298b:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102992:	f0 
f0102993:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f010299a:	00 
f010299b:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01029a2:	e8 99 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01029a7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01029ac:	75 24                	jne    f01029d2 <mem_init+0x10e3>
f01029ae:	c7 44 24 0c 79 7e 10 	movl   $0xf0107e79,0xc(%esp)
f01029b5:	f0 
f01029b6:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01029bd:	f0 
f01029be:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f01029c5:	00 
f01029c6:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01029cd:	e8 6e d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01029d2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01029d5:	74 24                	je     f01029fb <mem_init+0x110c>
f01029d7:	c7 44 24 0c 85 7e 10 	movl   $0xf0107e85,0xc(%esp)
f01029de:	f0 
f01029df:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01029e6:	f0 
f01029e7:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f01029ee:	00 
f01029ef:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01029f6:	e8 45 d6 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01029fb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102a02:	00 
f0102a03:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102a08:	89 04 24             	mov    %eax,(%esp)
f0102a0b:	e8 a2 ed ff ff       	call   f01017b2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a10:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0102a16:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a1b:	89 f8                	mov    %edi,%eax
f0102a1d:	e8 48 e5 ff ff       	call   f0100f6a <check_va2pa>
f0102a22:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a25:	74 24                	je     f0102a4b <mem_init+0x115c>
f0102a27:	c7 44 24 0c 6c 84 10 	movl   $0xf010846c,0xc(%esp)
f0102a2e:	f0 
f0102a2f:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102a36:	f0 
f0102a37:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0102a3e:	00 
f0102a3f:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102a46:	e8 f5 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a4b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a50:	89 f8                	mov    %edi,%eax
f0102a52:	e8 13 e5 ff ff       	call   f0100f6a <check_va2pa>
f0102a57:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a5a:	74 24                	je     f0102a80 <mem_init+0x1191>
f0102a5c:	c7 44 24 0c c8 84 10 	movl   $0xf01084c8,0xc(%esp)
f0102a63:	f0 
f0102a64:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102a6b:	f0 
f0102a6c:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f0102a73:	00 
f0102a74:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102a7b:	e8 c0 d5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102a80:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a85:	74 24                	je     f0102aab <mem_init+0x11bc>
f0102a87:	c7 44 24 0c 9a 7e 10 	movl   $0xf0107e9a,0xc(%esp)
f0102a8e:	f0 
f0102a8f:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102a96:	f0 
f0102a97:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0102a9e:	00 
f0102a9f:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102aa6:	e8 95 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102aab:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ab0:	74 24                	je     f0102ad6 <mem_init+0x11e7>
f0102ab2:	c7 44 24 0c 68 7e 10 	movl   $0xf0107e68,0xc(%esp)
f0102ab9:	f0 
f0102aba:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102ac1:	f0 
f0102ac2:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f0102ac9:	00 
f0102aca:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102ad1:	e8 6a d5 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102ad6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102add:	e8 c8 e9 ff ff       	call   f01014aa <page_alloc>
f0102ae2:	85 c0                	test   %eax,%eax
f0102ae4:	74 04                	je     f0102aea <mem_init+0x11fb>
f0102ae6:	39 c3                	cmp    %eax,%ebx
f0102ae8:	74 24                	je     f0102b0e <mem_init+0x121f>
f0102aea:	c7 44 24 0c f0 84 10 	movl   $0xf01084f0,0xc(%esp)
f0102af1:	f0 
f0102af2:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102af9:	f0 
f0102afa:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0102b01:	00 
f0102b02:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102b09:	e8 32 d5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102b0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b15:	e8 90 e9 ff ff       	call   f01014aa <page_alloc>
f0102b1a:	85 c0                	test   %eax,%eax
f0102b1c:	74 24                	je     f0102b42 <mem_init+0x1253>
f0102b1e:	c7 44 24 0c bc 7d 10 	movl   $0xf0107dbc,0xc(%esp)
f0102b25:	f0 
f0102b26:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102b2d:	f0 
f0102b2e:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f0102b35:	00 
f0102b36:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102b3d:	e8 fe d4 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b42:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102b47:	8b 08                	mov    (%eax),%ecx
f0102b49:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102b4f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b52:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0102b58:	c1 fa 03             	sar    $0x3,%edx
f0102b5b:	c1 e2 0c             	shl    $0xc,%edx
f0102b5e:	39 d1                	cmp    %edx,%ecx
f0102b60:	74 24                	je     f0102b86 <mem_init+0x1297>
f0102b62:	c7 44 24 0c 94 81 10 	movl   $0xf0108194,0xc(%esp)
f0102b69:	f0 
f0102b6a:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102b71:	f0 
f0102b72:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102b79:	00 
f0102b7a:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102b81:	e8 ba d4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102b86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b8f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102b94:	74 24                	je     f0102bba <mem_init+0x12cb>
f0102b96:	c7 44 24 0c 1f 7e 10 	movl   $0xf0107e1f,0xc(%esp)
f0102b9d:	f0 
f0102b9e:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102ba5:	f0 
f0102ba6:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f0102bad:	00 
f0102bae:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102bb5:	e8 86 d4 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102bba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bbd:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102bc3:	89 04 24             	mov    %eax,(%esp)
f0102bc6:	e8 6a e9 ff ff       	call   f0101535 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102bcb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102bd2:	00 
f0102bd3:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102bda:	00 
f0102bdb:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102be0:	89 04 24             	mov    %eax,(%esp)
f0102be3:	e8 b0 e9 ff ff       	call   f0101598 <pgdir_walk>
f0102be8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102beb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102bee:	8b 15 8c 1e 23 f0    	mov    0xf0231e8c,%edx
f0102bf4:	8b 7a 04             	mov    0x4(%edx),%edi
f0102bf7:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0102bfd:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f0102c03:	89 f8                	mov    %edi,%eax
f0102c05:	c1 e8 0c             	shr    $0xc,%eax
f0102c08:	39 c8                	cmp    %ecx,%eax
f0102c0a:	72 20                	jb     f0102c2c <mem_init+0x133d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c0c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102c10:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0102c17:	f0 
f0102c18:	c7 44 24 04 65 04 00 	movl   $0x465,0x4(%esp)
f0102c1f:	00 
f0102c20:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102c27:	e8 14 d4 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c2c:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102c32:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102c35:	74 24                	je     f0102c5b <mem_init+0x136c>
f0102c37:	c7 44 24 0c ab 7e 10 	movl   $0xf0107eab,0xc(%esp)
f0102c3e:	f0 
f0102c3f:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102c46:	f0 
f0102c47:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0102c4e:	00 
f0102c4f:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102c56:	e8 e5 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102c5b:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102c62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c65:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102c6b:	2b 05 90 1e 23 f0    	sub    0xf0231e90,%eax
f0102c71:	c1 f8 03             	sar    $0x3,%eax
f0102c74:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c77:	89 c2                	mov    %eax,%edx
f0102c79:	c1 ea 0c             	shr    $0xc,%edx
f0102c7c:	39 d1                	cmp    %edx,%ecx
f0102c7e:	77 20                	ja     f0102ca0 <mem_init+0x13b1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c80:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c84:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0102c8b:	f0 
f0102c8c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102c93:	00 
f0102c94:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f0102c9b:	e8 a0 d3 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102ca0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ca7:	00 
f0102ca8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102caf:	00 
	return (void *)(pa + KERNBASE);
f0102cb0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cb5:	89 04 24             	mov    %eax,(%esp)
f0102cb8:	e8 fa 38 00 00       	call   f01065b7 <memset>
	page_free(pp0);
f0102cbd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102cc0:	89 3c 24             	mov    %edi,(%esp)
f0102cc3:	e8 6d e8 ff ff       	call   f0101535 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102cc8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102ccf:	00 
f0102cd0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102cd7:	00 
f0102cd8:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102cdd:	89 04 24             	mov    %eax,(%esp)
f0102ce0:	e8 b3 e8 ff ff       	call   f0101598 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102ce5:	89 fa                	mov    %edi,%edx
f0102ce7:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0102ced:	c1 fa 03             	sar    $0x3,%edx
f0102cf0:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102cf3:	89 d0                	mov    %edx,%eax
f0102cf5:	c1 e8 0c             	shr    $0xc,%eax
f0102cf8:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0102cfe:	72 20                	jb     f0102d20 <mem_init+0x1431>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d00:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d04:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0102d0b:	f0 
f0102d0c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102d13:	00 
f0102d14:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f0102d1b:	e8 20 d3 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102d20:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102d26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102d29:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102d2f:	f6 00 01             	testb  $0x1,(%eax)
f0102d32:	74 24                	je     f0102d58 <mem_init+0x1469>
f0102d34:	c7 44 24 0c c3 7e 10 	movl   $0xf0107ec3,0xc(%esp)
f0102d3b:	f0 
f0102d3c:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102d43:	f0 
f0102d44:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0102d4b:	00 
f0102d4c:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102d53:	e8 e8 d2 ff ff       	call   f0100040 <_panic>
f0102d58:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102d5b:	39 d0                	cmp    %edx,%eax
f0102d5d:	75 d0                	jne    f0102d2f <mem_init+0x1440>
	kern_pgdir[0] = 0;
f0102d5f:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102d64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102d6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d6d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102d73:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102d76:	89 0d 40 12 23 f0    	mov    %ecx,0xf0231240

	// free the pages we took
	page_free(pp0);
f0102d7c:	89 04 24             	mov    %eax,(%esp)
f0102d7f:	e8 b1 e7 ff ff       	call   f0101535 <page_free>
	page_free(pp1);
f0102d84:	89 1c 24             	mov    %ebx,(%esp)
f0102d87:	e8 a9 e7 ff ff       	call   f0101535 <page_free>
	page_free(pp2);
f0102d8c:	89 34 24             	mov    %esi,(%esp)
f0102d8f:	e8 a1 e7 ff ff       	call   f0101535 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102d94:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102d9b:	00 
f0102d9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102da3:	e8 c2 ea ff ff       	call   f010186a <mmio_map_region>
f0102da8:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102daa:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102db1:	00 
f0102db2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102db9:	e8 ac ea ff ff       	call   f010186a <mmio_map_region>
f0102dbe:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102dc0:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102dc6:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102dcb:	77 08                	ja     f0102dd5 <mem_init+0x14e6>
f0102dcd:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102dd3:	77 24                	ja     f0102df9 <mem_init+0x150a>
f0102dd5:	c7 44 24 0c 14 85 10 	movl   $0xf0108514,0xc(%esp)
f0102ddc:	f0 
f0102ddd:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102de4:	f0 
f0102de5:	c7 44 24 04 80 04 00 	movl   $0x480,0x4(%esp)
f0102dec:	00 
f0102ded:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102df4:	e8 47 d2 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102df9:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102dff:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102e05:	77 08                	ja     f0102e0f <mem_init+0x1520>
f0102e07:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102e0d:	77 24                	ja     f0102e33 <mem_init+0x1544>
f0102e0f:	c7 44 24 0c 3c 85 10 	movl   $0xf010853c,0xc(%esp)
f0102e16:	f0 
f0102e17:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102e1e:	f0 
f0102e1f:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f0102e26:	00 
f0102e27:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102e2e:	e8 0d d2 ff ff       	call   f0100040 <_panic>
f0102e33:	89 da                	mov    %ebx,%edx
f0102e35:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102e37:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102e3d:	74 24                	je     f0102e63 <mem_init+0x1574>
f0102e3f:	c7 44 24 0c 64 85 10 	movl   $0xf0108564,0xc(%esp)
f0102e46:	f0 
f0102e47:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102e4e:	f0 
f0102e4f:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0102e56:	00 
f0102e57:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102e5e:	e8 dd d1 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0102e63:	39 c6                	cmp    %eax,%esi
f0102e65:	73 24                	jae    f0102e8b <mem_init+0x159c>
f0102e67:	c7 44 24 0c da 7e 10 	movl   $0xf0107eda,0xc(%esp)
f0102e6e:	f0 
f0102e6f:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102e76:	f0 
f0102e77:	c7 44 24 04 85 04 00 	movl   $0x485,0x4(%esp)
f0102e7e:	00 
f0102e7f:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102e86:	e8 b5 d1 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102e8b:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
f0102e91:	89 da                	mov    %ebx,%edx
f0102e93:	89 f8                	mov    %edi,%eax
f0102e95:	e8 d0 e0 ff ff       	call   f0100f6a <check_va2pa>
f0102e9a:	85 c0                	test   %eax,%eax
f0102e9c:	74 24                	je     f0102ec2 <mem_init+0x15d3>
f0102e9e:	c7 44 24 0c 8c 85 10 	movl   $0xf010858c,0xc(%esp)
f0102ea5:	f0 
f0102ea6:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102ead:	f0 
f0102eae:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f0102eb5:	00 
f0102eb6:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102ebd:	e8 7e d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102ec2:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102ec8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102ecb:	89 c2                	mov    %eax,%edx
f0102ecd:	89 f8                	mov    %edi,%eax
f0102ecf:	e8 96 e0 ff ff       	call   f0100f6a <check_va2pa>
f0102ed4:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102ed9:	74 24                	je     f0102eff <mem_init+0x1610>
f0102edb:	c7 44 24 0c b0 85 10 	movl   $0xf01085b0,0xc(%esp)
f0102ee2:	f0 
f0102ee3:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102eea:	f0 
f0102eeb:	c7 44 24 04 88 04 00 	movl   $0x488,0x4(%esp)
f0102ef2:	00 
f0102ef3:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102efa:	e8 41 d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102eff:	89 f2                	mov    %esi,%edx
f0102f01:	89 f8                	mov    %edi,%eax
f0102f03:	e8 62 e0 ff ff       	call   f0100f6a <check_va2pa>
f0102f08:	85 c0                	test   %eax,%eax
f0102f0a:	74 24                	je     f0102f30 <mem_init+0x1641>
f0102f0c:	c7 44 24 0c e0 85 10 	movl   $0xf01085e0,0xc(%esp)
f0102f13:	f0 
f0102f14:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102f1b:	f0 
f0102f1c:	c7 44 24 04 89 04 00 	movl   $0x489,0x4(%esp)
f0102f23:	00 
f0102f24:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102f2b:	e8 10 d1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102f30:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102f36:	89 f8                	mov    %edi,%eax
f0102f38:	e8 2d e0 ff ff       	call   f0100f6a <check_va2pa>
f0102f3d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f40:	74 24                	je     f0102f66 <mem_init+0x1677>
f0102f42:	c7 44 24 0c 04 86 10 	movl   $0xf0108604,0xc(%esp)
f0102f49:	f0 
f0102f4a:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102f51:	f0 
f0102f52:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
f0102f59:	00 
f0102f5a:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102f61:	e8 da d0 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102f66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f6d:	00 
f0102f6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f72:	89 3c 24             	mov    %edi,(%esp)
f0102f75:	e8 1e e6 ff ff       	call   f0101598 <pgdir_walk>
f0102f7a:	f6 00 1a             	testb  $0x1a,(%eax)
f0102f7d:	75 24                	jne    f0102fa3 <mem_init+0x16b4>
f0102f7f:	c7 44 24 0c 30 86 10 	movl   $0xf0108630,0xc(%esp)
f0102f86:	f0 
f0102f87:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102f8e:	f0 
f0102f8f:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f0102f96:	00 
f0102f97:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102f9e:	e8 9d d0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102fa3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102faa:	00 
f0102fab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102faf:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102fb4:	89 04 24             	mov    %eax,(%esp)
f0102fb7:	e8 dc e5 ff ff       	call   f0101598 <pgdir_walk>
f0102fbc:	f6 00 04             	testb  $0x4,(%eax)
f0102fbf:	74 24                	je     f0102fe5 <mem_init+0x16f6>
f0102fc1:	c7 44 24 0c 74 86 10 	movl   $0xf0108674,0xc(%esp)
f0102fc8:	f0 
f0102fc9:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0102fd0:	f0 
f0102fd1:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f0102fd8:	00 
f0102fd9:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0102fe0:	e8 5b d0 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102fe5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102fec:	00 
f0102fed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ff1:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0102ff6:	89 04 24             	mov    %eax,(%esp)
f0102ff9:	e8 9a e5 ff ff       	call   f0101598 <pgdir_walk>
f0102ffe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0103004:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010300b:	00 
f010300c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010300f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103013:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103018:	89 04 24             	mov    %eax,(%esp)
f010301b:	e8 78 e5 ff ff       	call   f0101598 <pgdir_walk>
f0103020:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0103026:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010302d:	00 
f010302e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103032:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103037:	89 04 24             	mov    %eax,(%esp)
f010303a:	e8 59 e5 ff ff       	call   f0101598 <pgdir_walk>
f010303f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0103045:	c7 04 24 ec 7e 10 f0 	movl   $0xf0107eec,(%esp)
f010304c:	e8 ff 12 00 00       	call   f0104350 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0103051:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0103056:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010305b:	77 20                	ja     f010307d <mem_init+0x178e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010305d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103061:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0103068:	f0 
f0103069:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f0103070:	00 
f0103071:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103078:	e8 c3 cf ff ff       	call   f0100040 <_panic>
f010307d:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103084:	00 
	return (physaddr_t)kva - KERNBASE;
f0103085:	05 00 00 00 10       	add    $0x10000000,%eax
f010308a:	89 04 24             	mov    %eax,(%esp)
f010308d:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103092:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103097:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010309c:	e8 dc e5 ff ff       	call   f010167d <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_P | PTE_U);
f01030a1:	a1 48 12 23 f0       	mov    0xf0231248,%eax
	if ((uint32_t)kva < KERNBASE)
f01030a6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030ab:	77 20                	ja     f01030cd <mem_init+0x17de>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030b1:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f01030b8:	f0 
f01030b9:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
f01030c0:	00 
f01030c1:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01030c8:	e8 73 cf ff ff       	call   f0100040 <_panic>
f01030cd:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01030d4:	00 
	return (physaddr_t)kva - KERNBASE;
f01030d5:	05 00 00 00 10       	add    $0x10000000,%eax
f01030da:	89 04 24             	mov    %eax,(%esp)
f01030dd:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01030e2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01030e7:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01030ec:	e8 8c e5 ff ff       	call   f010167d <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01030f1:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f01030f6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030fb:	77 20                	ja     f010311d <mem_init+0x182e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103101:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0103108:	f0 
f0103109:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
f0103110:	00 
f0103111:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103118:	e8 23 cf ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);
f010311d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103124:	00 
f0103125:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f010312c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103131:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103136:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f010313b:	e8 3d e5 ff ff       	call   f010167d <boot_map_region>
f0103140:	bf 00 30 27 f0       	mov    $0xf0273000,%edi
f0103145:	bb 00 30 23 f0       	mov    $0xf0233000,%ebx
f010314a:	be 00 80 ff ef       	mov    $0xefff8000,%esi
	if ((uint32_t)kva < KERNBASE)
f010314f:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0103155:	77 20                	ja     f0103177 <mem_init+0x1888>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103157:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010315b:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0103162:	f0 
f0103163:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f010316a:	00 
f010316b:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103172:	e8 c9 ce ff ff       	call   f0100040 <_panic>
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0103177:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010317e:	00 
f010317f:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0103185:	89 04 24             	mov    %eax,(%esp)
f0103188:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010318d:	89 f2                	mov    %esi,%edx
f010318f:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103194:	e8 e4 e4 ff ff       	call   f010167d <boot_map_region>
f0103199:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010319f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for ( int i = 0; i < NCPU; i++ )
f01031a5:	39 fb                	cmp    %edi,%ebx
f01031a7:	75 a6                	jne    f010314f <mem_init+0x1860>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE, 0, PTE_P | PTE_W);
f01031a9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01031b0:	00 
f01031b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031b8:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01031bd:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01031c2:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01031c7:	e8 b1 e4 ff ff       	call   f010167d <boot_map_region>
	pgdir = kern_pgdir;
f01031cc:	8b 3d 8c 1e 23 f0    	mov    0xf0231e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01031d2:	a1 88 1e 23 f0       	mov    0xf0231e88,%eax
f01031d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01031da:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01031e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01031e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01031e9:	8b 35 90 1e 23 f0    	mov    0xf0231e90,%esi
	if ((uint32_t)kva < KERNBASE)
f01031ef:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01031f2:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01031f8:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01031fb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103200:	eb 6a                	jmp    f010326c <mem_init+0x197d>
f0103202:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103208:	89 f8                	mov    %edi,%eax
f010320a:	e8 5b dd ff ff       	call   f0100f6a <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010320f:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103216:	77 20                	ja     f0103238 <mem_init+0x1949>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103218:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010321c:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0103223:	f0 
f0103224:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f010322b:	00 
f010322c:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103233:	e8 08 ce ff ff       	call   f0100040 <_panic>
f0103238:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010323b:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f010323e:	39 d0                	cmp    %edx,%eax
f0103240:	74 24                	je     f0103266 <mem_init+0x1977>
f0103242:	c7 44 24 0c a8 86 10 	movl   $0xf01086a8,0xc(%esp)
f0103249:	f0 
f010324a:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0103251:	f0 
f0103252:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0103259:	00 
f010325a:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103261:	e8 da cd ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0103266:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010326c:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f010326f:	77 91                	ja     f0103202 <mem_init+0x1913>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103271:	8b 1d 48 12 23 f0    	mov    0xf0231248,%ebx
	if ((uint32_t)kva < KERNBASE)
f0103277:	89 de                	mov    %ebx,%esi
f0103279:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010327e:	89 f8                	mov    %edi,%eax
f0103280:	e8 e5 dc ff ff       	call   f0100f6a <check_va2pa>
f0103285:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010328b:	77 20                	ja     f01032ad <mem_init+0x19be>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010328d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103291:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0103298:	f0 
f0103299:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01032a0:	00 
f01032a1:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01032a8:	e8 93 cd ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f01032ad:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01032b2:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f01032b8:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01032bb:	39 d0                	cmp    %edx,%eax
f01032bd:	74 24                	je     f01032e3 <mem_init+0x19f4>
f01032bf:	c7 44 24 0c dc 86 10 	movl   $0xf01086dc,0xc(%esp)
f01032c6:	f0 
f01032c7:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01032ce:	f0 
f01032cf:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01032d6:	00 
f01032d7:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01032de:	e8 5d cd ff ff       	call   f0100040 <_panic>
f01032e3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f01032e9:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01032ef:	0f 85 a8 05 00 00    	jne    f010389d <mem_init+0x1fae>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01032f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01032f8:	c1 e6 0c             	shl    $0xc,%esi
f01032fb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103300:	eb 3b                	jmp    f010333d <mem_init+0x1a4e>
f0103302:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103308:	89 f8                	mov    %edi,%eax
f010330a:	e8 5b dc ff ff       	call   f0100f6a <check_va2pa>
f010330f:	39 c3                	cmp    %eax,%ebx
f0103311:	74 24                	je     f0103337 <mem_init+0x1a48>
f0103313:	c7 44 24 0c 10 87 10 	movl   $0xf0108710,0xc(%esp)
f010331a:	f0 
f010331b:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0103322:	f0 
f0103323:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f010332a:	00 
f010332b:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103332:	e8 09 cd ff ff       	call   f0100040 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103337:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010333d:	39 f3                	cmp    %esi,%ebx
f010333f:	72 c1                	jb     f0103302 <mem_init+0x1a13>
f0103341:	c7 45 d0 00 30 23 f0 	movl   $0xf0233000,-0x30(%ebp)
f0103348:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010334f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0103354:	b8 00 30 23 f0       	mov    $0xf0233000,%eax
f0103359:	05 00 80 00 20       	add    $0x20008000,%eax
f010335e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0103361:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0103367:	89 45 cc             	mov    %eax,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010336a:	89 f2                	mov    %esi,%edx
f010336c:	89 f8                	mov    %edi,%eax
f010336e:	e8 f7 db ff ff       	call   f0100f6a <check_va2pa>
f0103373:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103376:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f010337c:	77 20                	ja     f010339e <mem_init+0x1aaf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010337e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103382:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0103389:	f0 
f010338a:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f0103391:	00 
f0103392:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103399:	e8 a2 cc ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f010339e:	89 f3                	mov    %esi,%ebx
f01033a0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01033a3:	03 4d d4             	add    -0x2c(%ebp),%ecx
f01033a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01033a9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01033ac:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01033af:	39 c2                	cmp    %eax,%edx
f01033b1:	74 24                	je     f01033d7 <mem_init+0x1ae8>
f01033b3:	c7 44 24 0c 38 87 10 	movl   $0xf0108738,0xc(%esp)
f01033ba:	f0 
f01033bb:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01033c2:	f0 
f01033c3:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01033ca:	00 
f01033cb:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01033d2:	e8 69 cc ff ff       	call   f0100040 <_panic>
f01033d7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01033dd:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f01033e0:	0f 85 a9 04 00 00    	jne    f010388f <mem_init+0x1fa0>
f01033e6:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f01033ec:	89 da                	mov    %ebx,%edx
f01033ee:	89 f8                	mov    %edi,%eax
f01033f0:	e8 75 db ff ff       	call   f0100f6a <check_va2pa>
f01033f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01033f8:	74 24                	je     f010341e <mem_init+0x1b2f>
f01033fa:	c7 44 24 0c 80 87 10 	movl   $0xf0108780,0xc(%esp)
f0103401:	f0 
f0103402:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0103409:	f0 
f010340a:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0103411:	00 
f0103412:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103419:	e8 22 cc ff ff       	call   f0100040 <_panic>
f010341e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103424:	39 de                	cmp    %ebx,%esi
f0103426:	75 c4                	jne    f01033ec <mem_init+0x1afd>
f0103428:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f010342e:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f0103435:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (n = 0; n < NCPU; n++) {
f010343c:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103442:	0f 85 19 ff ff ff    	jne    f0103361 <mem_init+0x1a72>
f0103448:	b8 00 00 00 00       	mov    $0x0,%eax
f010344d:	e9 c2 00 00 00       	jmp    f0103514 <mem_init+0x1c25>
		switch (i) {
f0103452:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103458:	83 fa 04             	cmp    $0x4,%edx
f010345b:	77 2e                	ja     f010348b <mem_init+0x1b9c>
			assert(pgdir[i] & PTE_P);
f010345d:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103461:	0f 85 aa 00 00 00    	jne    f0103511 <mem_init+0x1c22>
f0103467:	c7 44 24 0c 05 7f 10 	movl   $0xf0107f05,0xc(%esp)
f010346e:	f0 
f010346f:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0103476:	f0 
f0103477:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f010347e:	00 
f010347f:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103486:	e8 b5 cb ff ff       	call   f0100040 <_panic>
			if (i >= PDX(KERNBASE)) {
f010348b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103490:	76 55                	jbe    f01034e7 <mem_init+0x1bf8>
				assert(pgdir[i] & PTE_P);
f0103492:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103495:	f6 c2 01             	test   $0x1,%dl
f0103498:	75 24                	jne    f01034be <mem_init+0x1bcf>
f010349a:	c7 44 24 0c 05 7f 10 	movl   $0xf0107f05,0xc(%esp)
f01034a1:	f0 
f01034a2:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01034a9:	f0 
f01034aa:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f01034b1:	00 
f01034b2:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01034b9:	e8 82 cb ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01034be:	f6 c2 02             	test   $0x2,%dl
f01034c1:	75 4e                	jne    f0103511 <mem_init+0x1c22>
f01034c3:	c7 44 24 0c 16 7f 10 	movl   $0xf0107f16,0xc(%esp)
f01034ca:	f0 
f01034cb:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01034d2:	f0 
f01034d3:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f01034da:	00 
f01034db:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01034e2:	e8 59 cb ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f01034e7:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01034eb:	74 24                	je     f0103511 <mem_init+0x1c22>
f01034ed:	c7 44 24 0c 27 7f 10 	movl   $0xf0107f27,0xc(%esp)
f01034f4:	f0 
f01034f5:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01034fc:	f0 
f01034fd:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0103504:	00 
f0103505:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010350c:	e8 2f cb ff ff       	call   f0100040 <_panic>
	for (i = 0; i < NPDENTRIES; i++) {
f0103511:	83 c0 01             	add    $0x1,%eax
f0103514:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103519:	0f 85 33 ff ff ff    	jne    f0103452 <mem_init+0x1b63>
	cprintf("check_kern_pgdir() succeeded!\n");
f010351f:	c7 04 24 a4 87 10 f0 	movl   $0xf01087a4,(%esp)
f0103526:	e8 25 0e 00 00       	call   f0104350 <cprintf>
	lcr3(PADDR(kern_pgdir));
f010352b:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103530:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103535:	77 20                	ja     f0103557 <mem_init+0x1c68>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103537:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010353b:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0103542:	f0 
f0103543:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
f010354a:	00 
f010354b:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103552:	e8 e9 ca ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103557:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010355c:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f010355f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103564:	e8 70 da ff ff       	call   f0100fd9 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0103569:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010356c:	83 e0 f3             	and    $0xfffffff3,%eax
f010356f:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0103574:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103577:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010357e:	e8 27 df ff ff       	call   f01014aa <page_alloc>
f0103583:	89 c3                	mov    %eax,%ebx
f0103585:	85 c0                	test   %eax,%eax
f0103587:	75 24                	jne    f01035ad <mem_init+0x1cbe>
f0103589:	c7 44 24 0c 11 7d 10 	movl   $0xf0107d11,0xc(%esp)
f0103590:	f0 
f0103591:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0103598:	f0 
f0103599:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f01035a0:	00 
f01035a1:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01035a8:	e8 93 ca ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01035ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035b4:	e8 f1 de ff ff       	call   f01014aa <page_alloc>
f01035b9:	89 c7                	mov    %eax,%edi
f01035bb:	85 c0                	test   %eax,%eax
f01035bd:	75 24                	jne    f01035e3 <mem_init+0x1cf4>
f01035bf:	c7 44 24 0c 27 7d 10 	movl   $0xf0107d27,0xc(%esp)
f01035c6:	f0 
f01035c7:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01035ce:	f0 
f01035cf:	c7 44 24 04 a3 04 00 	movl   $0x4a3,0x4(%esp)
f01035d6:	00 
f01035d7:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01035de:	e8 5d ca ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01035e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035ea:	e8 bb de ff ff       	call   f01014aa <page_alloc>
f01035ef:	89 c6                	mov    %eax,%esi
f01035f1:	85 c0                	test   %eax,%eax
f01035f3:	75 24                	jne    f0103619 <mem_init+0x1d2a>
f01035f5:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f01035fc:	f0 
f01035fd:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0103604:	f0 
f0103605:	c7 44 24 04 a4 04 00 	movl   $0x4a4,0x4(%esp)
f010360c:	00 
f010360d:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103614:	e8 27 ca ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103619:	89 1c 24             	mov    %ebx,(%esp)
f010361c:	e8 14 df ff ff       	call   f0101535 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0103621:	89 f8                	mov    %edi,%eax
f0103623:	e8 fd d8 ff ff       	call   f0100f25 <page2kva>
f0103628:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010362f:	00 
f0103630:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103637:	00 
f0103638:	89 04 24             	mov    %eax,(%esp)
f010363b:	e8 77 2f 00 00       	call   f01065b7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103640:	89 f0                	mov    %esi,%eax
f0103642:	e8 de d8 ff ff       	call   f0100f25 <page2kva>
f0103647:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010364e:	00 
f010364f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103656:	00 
f0103657:	89 04 24             	mov    %eax,(%esp)
f010365a:	e8 58 2f 00 00       	call   f01065b7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010365f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103666:	00 
f0103667:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010366e:	00 
f010366f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103673:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103678:	89 04 24             	mov    %eax,(%esp)
f010367b:	e8 7b e1 ff ff       	call   f01017fb <page_insert>
	assert(pp1->pp_ref == 1);
f0103680:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103685:	74 24                	je     f01036ab <mem_init+0x1dbc>
f0103687:	c7 44 24 0c 0e 7e 10 	movl   $0xf0107e0e,0xc(%esp)
f010368e:	f0 
f010368f:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0103696:	f0 
f0103697:	c7 44 24 04 a9 04 00 	movl   $0x4a9,0x4(%esp)
f010369e:	00 
f010369f:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01036a6:	e8 95 c9 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01036ab:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01036b2:	01 01 01 
f01036b5:	74 24                	je     f01036db <mem_init+0x1dec>
f01036b7:	c7 44 24 0c c4 87 10 	movl   $0xf01087c4,0xc(%esp)
f01036be:	f0 
f01036bf:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01036c6:	f0 
f01036c7:	c7 44 24 04 aa 04 00 	movl   $0x4aa,0x4(%esp)
f01036ce:	00 
f01036cf:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01036d6:	e8 65 c9 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01036db:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01036e2:	00 
f01036e3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01036ea:	00 
f01036eb:	89 74 24 04          	mov    %esi,0x4(%esp)
f01036ef:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01036f4:	89 04 24             	mov    %eax,(%esp)
f01036f7:	e8 ff e0 ff ff       	call   f01017fb <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01036fc:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103703:	02 02 02 
f0103706:	74 24                	je     f010372c <mem_init+0x1e3d>
f0103708:	c7 44 24 0c e8 87 10 	movl   $0xf01087e8,0xc(%esp)
f010370f:	f0 
f0103710:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0103717:	f0 
f0103718:	c7 44 24 04 ac 04 00 	movl   $0x4ac,0x4(%esp)
f010371f:	00 
f0103720:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103727:	e8 14 c9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010372c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103731:	74 24                	je     f0103757 <mem_init+0x1e68>
f0103733:	c7 44 24 0c 30 7e 10 	movl   $0xf0107e30,0xc(%esp)
f010373a:	f0 
f010373b:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0103742:	f0 
f0103743:	c7 44 24 04 ad 04 00 	movl   $0x4ad,0x4(%esp)
f010374a:	00 
f010374b:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f0103752:	e8 e9 c8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103757:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010375c:	74 24                	je     f0103782 <mem_init+0x1e93>
f010375e:	c7 44 24 0c 9a 7e 10 	movl   $0xf0107e9a,0xc(%esp)
f0103765:	f0 
f0103766:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010376d:	f0 
f010376e:	c7 44 24 04 ae 04 00 	movl   $0x4ae,0x4(%esp)
f0103775:	00 
f0103776:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010377d:	e8 be c8 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103782:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103789:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010378c:	89 f0                	mov    %esi,%eax
f010378e:	e8 92 d7 ff ff       	call   f0100f25 <page2kva>
f0103793:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0103799:	74 24                	je     f01037bf <mem_init+0x1ed0>
f010379b:	c7 44 24 0c 0c 88 10 	movl   $0xf010880c,0xc(%esp)
f01037a2:	f0 
f01037a3:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01037aa:	f0 
f01037ab:	c7 44 24 04 b0 04 00 	movl   $0x4b0,0x4(%esp)
f01037b2:	00 
f01037b3:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01037ba:	e8 81 c8 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01037bf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01037c6:	00 
f01037c7:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f01037cc:	89 04 24             	mov    %eax,(%esp)
f01037cf:	e8 de df ff ff       	call   f01017b2 <page_remove>
	assert(pp2->pp_ref == 0);
f01037d4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01037d9:	74 24                	je     f01037ff <mem_init+0x1f10>
f01037db:	c7 44 24 0c 68 7e 10 	movl   $0xf0107e68,0xc(%esp)
f01037e2:	f0 
f01037e3:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f01037ea:	f0 
f01037eb:	c7 44 24 04 b2 04 00 	movl   $0x4b2,0x4(%esp)
f01037f2:	00 
f01037f3:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f01037fa:	e8 41 c8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01037ff:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
f0103804:	8b 08                	mov    (%eax),%ecx
f0103806:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	return (pp - pages) << PGSHIFT;
f010380c:	89 da                	mov    %ebx,%edx
f010380e:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0103814:	c1 fa 03             	sar    $0x3,%edx
f0103817:	c1 e2 0c             	shl    $0xc,%edx
f010381a:	39 d1                	cmp    %edx,%ecx
f010381c:	74 24                	je     f0103842 <mem_init+0x1f53>
f010381e:	c7 44 24 0c 94 81 10 	movl   $0xf0108194,0xc(%esp)
f0103825:	f0 
f0103826:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010382d:	f0 
f010382e:	c7 44 24 04 b5 04 00 	movl   $0x4b5,0x4(%esp)
f0103835:	00 
f0103836:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010383d:	e8 fe c7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103842:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103848:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010384d:	74 24                	je     f0103873 <mem_init+0x1f84>
f010384f:	c7 44 24 0c 1f 7e 10 	movl   $0xf0107e1f,0xc(%esp)
f0103856:	f0 
f0103857:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f010385e:	f0 
f010385f:	c7 44 24 04 b7 04 00 	movl   $0x4b7,0x4(%esp)
f0103866:	00 
f0103867:	c7 04 24 ef 7b 10 f0 	movl   $0xf0107bef,(%esp)
f010386e:	e8 cd c7 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103873:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103879:	89 1c 24             	mov    %ebx,(%esp)
f010387c:	e8 b4 dc ff ff       	call   f0101535 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103881:	c7 04 24 38 88 10 f0 	movl   $0xf0108838,(%esp)
f0103888:	e8 c3 0a 00 00       	call   f0104350 <cprintf>
f010388d:	eb 1c                	jmp    f01038ab <mem_init+0x1fbc>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010388f:	89 da                	mov    %ebx,%edx
f0103891:	89 f8                	mov    %edi,%eax
f0103893:	e8 d2 d6 ff ff       	call   f0100f6a <check_va2pa>
f0103898:	e9 0c fb ff ff       	jmp    f01033a9 <mem_init+0x1aba>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010389d:	89 da                	mov    %ebx,%edx
f010389f:	89 f8                	mov    %edi,%eax
f01038a1:	e8 c4 d6 ff ff       	call   f0100f6a <check_va2pa>
f01038a6:	e9 0d fa ff ff       	jmp    f01032b8 <mem_init+0x19c9>
}
f01038ab:	83 c4 4c             	add    $0x4c,%esp
f01038ae:	5b                   	pop    %ebx
f01038af:	5e                   	pop    %esi
f01038b0:	5f                   	pop    %edi
f01038b1:	5d                   	pop    %ebp
f01038b2:	c3                   	ret    

f01038b3 <user_mem_check>:
{
f01038b3:	55                   	push   %ebp
f01038b4:	89 e5                	mov    %esp,%ebp
f01038b6:	57                   	push   %edi
f01038b7:	56                   	push   %esi
f01038b8:	53                   	push   %ebx
f01038b9:	83 ec 1c             	sub    $0x1c,%esp
f01038bc:	8b 7d 08             	mov    0x8(%ebp),%edi
f01038bf:	8b 75 14             	mov    0x14(%ebp),%esi
	uint32_t start = ROUNDDOWN(addr, PGSIZE);
f01038c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01038c5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = ROUNDUP(addr + len, PGSIZE);
f01038cb:	8b 45 10             	mov    0x10(%ebp),%eax
f01038ce:	8b 55 0c             	mov    0xc(%ebp),%edx
f01038d1:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f01038d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01038dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	while (start < end)
f01038e0:	eb 56                	jmp    f0103938 <user_mem_check+0x85>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *)start, 0);
f01038e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01038e9:	00 
f01038ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01038ee:	8b 47 60             	mov    0x60(%edi),%eax
f01038f1:	89 04 24             	mov    %eax,(%esp)
f01038f4:	e8 9f dc ff ff       	call   f0101598 <pgdir_walk>
		if (start >= ULIM || pte == NULL || !(*pte & PTE_P) || (*pte & perm) != perm)
f01038f9:	85 c0                	test   %eax,%eax
f01038fb:	74 14                	je     f0103911 <user_mem_check+0x5e>
f01038fd:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103903:	77 0c                	ja     f0103911 <user_mem_check+0x5e>
f0103905:	8b 00                	mov    (%eax),%eax
f0103907:	a8 01                	test   $0x1,%al
f0103909:	74 06                	je     f0103911 <user_mem_check+0x5e>
f010390b:	21 f0                	and    %esi,%eax
f010390d:	39 c6                	cmp    %eax,%esi
f010390f:	74 21                	je     f0103932 <user_mem_check+0x7f>
			if (start < addr)
f0103911:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0103914:	76 0f                	jbe    f0103925 <user_mem_check+0x72>
				user_mem_check_addr = addr;
f0103916:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103919:	a3 3c 12 23 f0       	mov    %eax,0xf023123c
			return -E_FAULT;
f010391e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103923:	eb 1d                	jmp    f0103942 <user_mem_check+0x8f>
				user_mem_check_addr = start;
f0103925:	89 1d 3c 12 23 f0    	mov    %ebx,0xf023123c
			return -E_FAULT;
f010392b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103930:	eb 10                	jmp    f0103942 <user_mem_check+0x8f>
		start += PGSIZE;
f0103932:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	while (start < end)
f0103938:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010393b:	72 a5                	jb     f01038e2 <user_mem_check+0x2f>
	return 0;
f010393d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103942:	83 c4 1c             	add    $0x1c,%esp
f0103945:	5b                   	pop    %ebx
f0103946:	5e                   	pop    %esi
f0103947:	5f                   	pop    %edi
f0103948:	5d                   	pop    %ebp
f0103949:	c3                   	ret    

f010394a <user_mem_assert>:
{
f010394a:	55                   	push   %ebp
f010394b:	89 e5                	mov    %esp,%ebp
f010394d:	53                   	push   %ebx
f010394e:	83 ec 14             	sub    $0x14,%esp
f0103951:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103954:	8b 45 14             	mov    0x14(%ebp),%eax
f0103957:	83 c8 04             	or     $0x4,%eax
f010395a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010395e:	8b 45 10             	mov    0x10(%ebp),%eax
f0103961:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103965:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103968:	89 44 24 04          	mov    %eax,0x4(%esp)
f010396c:	89 1c 24             	mov    %ebx,(%esp)
f010396f:	e8 3f ff ff ff       	call   f01038b3 <user_mem_check>
f0103974:	85 c0                	test   %eax,%eax
f0103976:	79 24                	jns    f010399c <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103978:	a1 3c 12 23 f0       	mov    0xf023123c,%eax
f010397d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103981:	8b 43 48             	mov    0x48(%ebx),%eax
f0103984:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103988:	c7 04 24 64 88 10 f0 	movl   $0xf0108864,(%esp)
f010398f:	e8 bc 09 00 00       	call   f0104350 <cprintf>
		env_destroy(env);	// may not return
f0103994:	89 1c 24             	mov    %ebx,(%esp)
f0103997:	e8 05 07 00 00       	call   f01040a1 <env_destroy>
}
f010399c:	83 c4 14             	add    $0x14,%esp
f010399f:	5b                   	pop    %ebx
f01039a0:	5d                   	pop    %ebp
f01039a1:	c3                   	ret    

f01039a2 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01039a2:	55                   	push   %ebp
f01039a3:	89 e5                	mov    %esp,%ebp
f01039a5:	57                   	push   %edi
f01039a6:	56                   	push   %esi
f01039a7:	53                   	push   %ebx
f01039a8:	83 ec 1c             	sub    $0x1c,%esp
f01039ab:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start = ROUNDDOWN(va, PGSIZE);
f01039ad:	89 d3                	mov    %edx,%ebx
f01039af:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *end = ROUNDUP(va+len, PGSIZE);
f01039b5:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f01039bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01039c1:	89 c6                	mov    %eax,%esi

	if ((uint32_t)end > UTOP)
f01039c3:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f01039c8:	0f 86 8d 00 00 00    	jbe    f0103a5b <region_alloc+0xb9>
		panic("region_alloc: Not proper location\n");
f01039ce:	c7 44 24 08 9c 88 10 	movl   $0xf010889c,0x8(%esp)
f01039d5:	f0 
f01039d6:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f01039dd:	00 
f01039de:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f01039e5:	e8 56 c6 ff ff       	call   f0100040 <_panic>

	while ( start < end )
	{
		struct PageInfo *pp = page_alloc(0);
f01039ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01039f1:	e8 b4 da ff ff       	call   f01014aa <page_alloc>

		if ( !pp )
f01039f6:	85 c0                	test   %eax,%eax
f01039f8:	75 1c                	jne    f0103a16 <region_alloc+0x74>
			panic("region_alloc: over memory");
f01039fa:	c7 44 24 08 ea 88 10 	movl   $0xf01088ea,0x8(%esp)
f0103a01:	f0 
f0103a02:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f0103a09:	00 
f0103a0a:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f0103a11:	e8 2a c6 ff ff       	call   f0100040 <_panic>

		int r = page_insert(e->env_pgdir, pp, start, PTE_U | PTE_W);
f0103a16:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103a1d:	00 
f0103a1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103a22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a26:	8b 47 60             	mov    0x60(%edi),%eax
f0103a29:	89 04 24             	mov    %eax,(%esp)
f0103a2c:	e8 ca dd ff ff       	call   f01017fb <page_insert>

		if ( r != 0 )
f0103a31:	85 c0                	test   %eax,%eax
f0103a33:	74 20                	je     f0103a55 <region_alloc+0xb3>
			panic("region_alloc: %e", r);
f0103a35:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a39:	c7 44 24 08 04 89 10 	movl   $0xf0108904,0x8(%esp)
f0103a40:	f0 
f0103a41:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f0103a48:	00 
f0103a49:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f0103a50:	e8 eb c5 ff ff       	call   f0100040 <_panic>
		
		start += PGSIZE;
f0103a55:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	while ( start < end )
f0103a5b:	39 f3                	cmp    %esi,%ebx
f0103a5d:	72 8b                	jb     f01039ea <region_alloc+0x48>
	}
}
f0103a5f:	83 c4 1c             	add    $0x1c,%esp
f0103a62:	5b                   	pop    %ebx
f0103a63:	5e                   	pop    %esi
f0103a64:	5f                   	pop    %edi
f0103a65:	5d                   	pop    %ebp
f0103a66:	c3                   	ret    

f0103a67 <envid2env>:
{
f0103a67:	55                   	push   %ebp
f0103a68:	89 e5                	mov    %esp,%ebp
f0103a6a:	56                   	push   %esi
f0103a6b:	53                   	push   %ebx
f0103a6c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a6f:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0103a72:	85 c0                	test   %eax,%eax
f0103a74:	75 1a                	jne    f0103a90 <envid2env+0x29>
		*env_store = curenv;
f0103a76:	e8 8e 31 00 00       	call   f0106c09 <cpunum>
f0103a7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a7e:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103a87:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103a89:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a8e:	eb 70                	jmp    f0103b00 <envid2env+0x99>
	e = &envs[ENVX(envid)];
f0103a90:	89 c3                	mov    %eax,%ebx
f0103a92:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103a98:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103a9b:	03 1d 48 12 23 f0    	add    0xf0231248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103aa1:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103aa5:	74 05                	je     f0103aac <envid2env+0x45>
f0103aa7:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103aaa:	74 10                	je     f0103abc <envid2env+0x55>
		*env_store = 0;
f0103aac:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103aaf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103ab5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103aba:	eb 44                	jmp    f0103b00 <envid2env+0x99>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103abc:	84 d2                	test   %dl,%dl
f0103abe:	74 36                	je     f0103af6 <envid2env+0x8f>
f0103ac0:	e8 44 31 00 00       	call   f0106c09 <cpunum>
f0103ac5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ac8:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f0103ace:	74 26                	je     f0103af6 <envid2env+0x8f>
f0103ad0:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103ad3:	e8 31 31 00 00       	call   f0106c09 <cpunum>
f0103ad8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103adb:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103ae1:	3b 70 48             	cmp    0x48(%eax),%esi
f0103ae4:	74 10                	je     f0103af6 <envid2env+0x8f>
		*env_store = 0;
f0103ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ae9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103aef:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103af4:	eb 0a                	jmp    f0103b00 <envid2env+0x99>
	*env_store = e;
f0103af6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103af9:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103afb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103b00:	5b                   	pop    %ebx
f0103b01:	5e                   	pop    %esi
f0103b02:	5d                   	pop    %ebp
f0103b03:	c3                   	ret    

f0103b04 <env_init_percpu>:
{
f0103b04:	55                   	push   %ebp
f0103b05:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f0103b07:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103b0c:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103b0f:	b8 23 00 00 00       	mov    $0x23,%eax
f0103b14:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103b16:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103b18:	b0 10                	mov    $0x10,%al
f0103b1a:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103b1c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103b1e:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103b20:	ea 27 3b 10 f0 08 00 	ljmp   $0x8,$0xf0103b27
	asm volatile("lldt %0" : : "r" (sel));
f0103b27:	b0 00                	mov    $0x0,%al
f0103b29:	0f 00 d0             	lldt   %ax
}
f0103b2c:	5d                   	pop    %ebp
f0103b2d:	c3                   	ret    

f0103b2e <env_init>:
{
f0103b2e:	55                   	push   %ebp
f0103b2f:	89 e5                	mov    %esp,%ebp
f0103b31:	56                   	push   %esi
f0103b32:	53                   	push   %ebx
		envs[i].env_id = 0;
f0103b33:	8b 35 48 12 23 f0    	mov    0xf0231248,%esi
f0103b39:	8b 0d 4c 12 23 f0    	mov    0xf023124c,%ecx
f0103b3f:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103b45:	ba 00 04 00 00       	mov    $0x400,%edx
f0103b4a:	89 c3                	mov    %eax,%ebx
f0103b4c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f0103b53:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0103b5a:	89 48 44             	mov    %ecx,0x44(%eax)
f0103b5d:	83 e8 7c             	sub    $0x7c,%eax
	for (int i = NENV-1; i >= 0; i--)
f0103b60:	83 ea 01             	sub    $0x1,%edx
f0103b63:	74 04                	je     f0103b69 <env_init+0x3b>
		env_free_list = &envs[i];
f0103b65:	89 d9                	mov    %ebx,%ecx
f0103b67:	eb e1                	jmp    f0103b4a <env_init+0x1c>
f0103b69:	89 35 4c 12 23 f0    	mov    %esi,0xf023124c
	env_init_percpu();
f0103b6f:	e8 90 ff ff ff       	call   f0103b04 <env_init_percpu>
}
f0103b74:	5b                   	pop    %ebx
f0103b75:	5e                   	pop    %esi
f0103b76:	5d                   	pop    %ebp
f0103b77:	c3                   	ret    

f0103b78 <env_alloc>:
{
f0103b78:	55                   	push   %ebp
f0103b79:	89 e5                	mov    %esp,%ebp
f0103b7b:	56                   	push   %esi
f0103b7c:	53                   	push   %ebx
f0103b7d:	83 ec 10             	sub    $0x10,%esp
	if (!(e = env_free_list))
f0103b80:	8b 1d 4c 12 23 f0    	mov    0xf023124c,%ebx
f0103b86:	85 db                	test   %ebx,%ebx
f0103b88:	0f 84 96 01 00 00    	je     f0103d24 <env_alloc+0x1ac>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103b8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103b95:	e8 10 d9 ff ff       	call   f01014aa <page_alloc>
f0103b9a:	85 c0                	test   %eax,%eax
f0103b9c:	0f 84 89 01 00 00    	je     f0103d2b <env_alloc+0x1b3>
f0103ba2:	89 c2                	mov    %eax,%edx
f0103ba4:	2b 15 90 1e 23 f0    	sub    0xf0231e90,%edx
f0103baa:	c1 fa 03             	sar    $0x3,%edx
f0103bad:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103bb0:	89 d1                	mov    %edx,%ecx
f0103bb2:	c1 e9 0c             	shr    $0xc,%ecx
f0103bb5:	3b 0d 88 1e 23 f0    	cmp    0xf0231e88,%ecx
f0103bbb:	72 20                	jb     f0103bdd <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103bbd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103bc1:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0103bc8:	f0 
f0103bc9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103bd0:	00 
f0103bd1:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f0103bd8:	e8 63 c4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103bdd:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103be3:	89 53 60             	mov    %edx,0x60(%ebx)
	e->env_pgdir = page2kva(p);
f0103be6:	ba ec 0e 00 00       	mov    $0xeec,%edx
		e->env_pgdir[i] = kern_pgdir[i];
f0103beb:	8b 0d 8c 1e 23 f0    	mov    0xf0231e8c,%ecx
f0103bf1:	8b 34 11             	mov    (%ecx,%edx,1),%esi
f0103bf4:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0103bf7:	89 34 11             	mov    %esi,(%ecx,%edx,1)
f0103bfa:	83 c2 04             	add    $0x4,%edx
	for (int i = PDX(UTOP); i < NPDENTRIES; ++i)
f0103bfd:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0103c03:	75 e6                	jne    f0103beb <env_alloc+0x73>
	p->pp_ref++;
f0103c05:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103c0a:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103c0d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c12:	77 20                	ja     f0103c34 <env_alloc+0xbc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c14:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c18:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0103c1f:	f0 
f0103c20:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f0103c27:	00 
f0103c28:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f0103c2f:	e8 0c c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103c34:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103c3a:	83 ca 05             	or     $0x5,%edx
f0103c3d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103c43:	8b 43 48             	mov    0x48(%ebx),%eax
f0103c46:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103c4b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103c50:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103c55:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103c58:	89 da                	mov    %ebx,%edx
f0103c5a:	2b 15 48 12 23 f0    	sub    0xf0231248,%edx
f0103c60:	c1 fa 02             	sar    $0x2,%edx
f0103c63:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103c69:	09 d0                	or     %edx,%eax
f0103c6b:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c71:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103c74:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103c7b:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103c82:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103c89:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103c90:	00 
f0103c91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c98:	00 
f0103c99:	89 1c 24             	mov    %ebx,(%esp)
f0103c9c:	e8 16 29 00 00       	call   f01065b7 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103ca1:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103ca7:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103cad:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103cb3:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103cba:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f0103cc0:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f0103cc7:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103cce:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103cd2:	8b 43 44             	mov    0x44(%ebx),%eax
f0103cd5:	a3 4c 12 23 f0       	mov    %eax,0xf023124c
	*newenv_store = e;
f0103cda:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cdd:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103cdf:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103ce2:	e8 22 2f 00 00       	call   f0106c09 <cpunum>
f0103ce7:	6b d0 74             	imul   $0x74,%eax,%edx
f0103cea:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cef:	83 ba 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%edx)
f0103cf6:	74 11                	je     f0103d09 <env_alloc+0x191>
f0103cf8:	e8 0c 2f 00 00       	call   f0106c09 <cpunum>
f0103cfd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d00:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103d06:	8b 40 48             	mov    0x48(%eax),%eax
f0103d09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d11:	c7 04 24 15 89 10 f0 	movl   $0xf0108915,(%esp)
f0103d18:	e8 33 06 00 00       	call   f0104350 <cprintf>
	return 0;
f0103d1d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d22:	eb 0c                	jmp    f0103d30 <env_alloc+0x1b8>
		return -E_NO_FREE_ENV;
f0103d24:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103d29:	eb 05                	jmp    f0103d30 <env_alloc+0x1b8>
		return -E_NO_MEM;
f0103d2b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f0103d30:	83 c4 10             	add    $0x10,%esp
f0103d33:	5b                   	pop    %ebx
f0103d34:	5e                   	pop    %esi
f0103d35:	5d                   	pop    %ebp
f0103d36:	c3                   	ret    

f0103d37 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103d37:	55                   	push   %ebp
f0103d38:	89 e5                	mov    %esp,%ebp
f0103d3a:	57                   	push   %edi
f0103d3b:	56                   	push   %esi
f0103d3c:	53                   	push   %ebx
f0103d3d:	83 ec 3c             	sub    $0x3c,%esp
f0103d40:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e = NULL;
f0103d43:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int r = env_alloc(&e, 0);
f0103d4a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103d51:	00 
f0103d52:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103d55:	89 04 24             	mov    %eax,(%esp)
f0103d58:	e8 1b fe ff ff       	call   f0103b78 <env_alloc>

	if ( r != 0 )
f0103d5d:	85 c0                	test   %eax,%eax
f0103d5f:	74 20                	je     f0103d81 <env_create+0x4a>
		panic("env_create: %e\n",r);
f0103d61:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d65:	c7 44 24 08 2a 89 10 	movl   $0xf010892a,0x8(%esp)
f0103d6c:	f0 
f0103d6d:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f0103d74:	00 
f0103d75:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f0103d7c:	e8 bf c2 ff ff       	call   f0100040 <_panic>

	load_icode(e, binary);
f0103d81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d84:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if ( elf->e_magic != ELF_MAGIC )
f0103d87:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103d8d:	74 1c                	je     f0103dab <env_create+0x74>
		panic("load_icode: invalid elf header");
f0103d8f:	c7 44 24 08 c0 88 10 	movl   $0xf01088c0,0x8(%esp)
f0103d96:	f0 
f0103d97:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
f0103d9e:	00 
f0103d9f:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f0103da6:	e8 95 c2 ff ff       	call   f0100040 <_panic>
	asm volatile("movl %%cr3,%0" : "=r" (val));
f0103dab:	0f 20 d8             	mov    %cr3,%eax
f0103dae:	89 45 d0             	mov    %eax,-0x30(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103db1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103db4:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103db7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103dbc:	77 20                	ja     f0103dde <env_create+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103dbe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dc2:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0103dc9:	f0 
f0103dca:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f0103dd1:	00 
f0103dd2:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f0103dd9:	e8 62 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103dde:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103de3:	0f 22 d8             	mov    %eax,%cr3
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff);
f0103de6:	89 fb                	mov    %edi,%ebx
f0103de8:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr *eph = ph + elf->e_phnum;
f0103deb:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103def:	c1 e6 05             	shl    $0x5,%esi
f0103df2:	01 de                	add    %ebx,%esi
f0103df4:	eb 71                	jmp    f0103e67 <env_create+0x130>
		if ( ph->p_type == ELF_PROG_LOAD )
f0103df6:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103df9:	75 69                	jne    f0103e64 <env_create+0x12d>
			if ( ph->p_filesz > ph->p_memsz)
f0103dfb:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103dfe:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103e01:	76 1c                	jbe    f0103e1f <env_create+0xe8>
				panic("load_icode: over memory size");
f0103e03:	c7 44 24 08 3a 89 10 	movl   $0xf010893a,0x8(%esp)
f0103e0a:	f0 
f0103e0b:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f0103e12:	00 
f0103e13:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f0103e1a:	e8 21 c2 ff ff       	call   f0100040 <_panic>
			region_alloc(e, (uint8_t *)ph->p_va, ph->p_memsz);
f0103e1f:	8b 53 08             	mov    0x8(%ebx),%edx
f0103e22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103e25:	e8 78 fb ff ff       	call   f01039a2 <region_alloc>
			memcpy((uint8_t *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103e2a:	8b 43 10             	mov    0x10(%ebx),%eax
f0103e2d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e31:	89 f8                	mov    %edi,%eax
f0103e33:	03 43 04             	add    0x4(%ebx),%eax
f0103e36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e3a:	8b 43 08             	mov    0x8(%ebx),%eax
f0103e3d:	89 04 24             	mov    %eax,(%esp)
f0103e40:	e8 27 28 00 00       	call   f010666c <memcpy>
			memset((uint8_t *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103e45:	8b 43 10             	mov    0x10(%ebx),%eax
f0103e48:	8b 53 14             	mov    0x14(%ebx),%edx
f0103e4b:	29 c2                	sub    %eax,%edx
f0103e4d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103e51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103e58:	00 
f0103e59:	03 43 08             	add    0x8(%ebx),%eax
f0103e5c:	89 04 24             	mov    %eax,(%esp)
f0103e5f:	e8 53 27 00 00       	call   f01065b7 <memset>
	for (; ph < eph; ph++)
f0103e64:	83 c3 20             	add    $0x20,%ebx
f0103e67:	39 de                	cmp    %ebx,%esi
f0103e69:	77 8b                	ja     f0103df6 <env_create+0xbf>
	e->env_tf.tf_eip = elf->e_entry;
f0103e6b:	8b 47 18             	mov    0x18(%edi),%eax
f0103e6e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103e71:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103e74:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103e79:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103e7e:	89 f8                	mov    %edi,%eax
f0103e80:	e8 1d fb ff ff       	call   f01039a2 <region_alloc>
f0103e85:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103e88:	0f 22 d8             	mov    %eax,%cr3
	e->env_type = type;
f0103e8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e8e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103e91:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103e94:	83 c4 3c             	add    $0x3c,%esp
f0103e97:	5b                   	pop    %ebx
f0103e98:	5e                   	pop    %esi
f0103e99:	5f                   	pop    %edi
f0103e9a:	5d                   	pop    %ebp
f0103e9b:	c3                   	ret    

f0103e9c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103e9c:	55                   	push   %ebp
f0103e9d:	89 e5                	mov    %esp,%ebp
f0103e9f:	57                   	push   %edi
f0103ea0:	56                   	push   %esi
f0103ea1:	53                   	push   %ebx
f0103ea2:	83 ec 2c             	sub    $0x2c,%esp
f0103ea5:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ea8:	e8 5c 2d 00 00       	call   f0106c09 <cpunum>
f0103ead:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eb0:	39 b8 28 20 23 f0    	cmp    %edi,-0xfdcdfd8(%eax)
f0103eb6:	75 34                	jne    f0103eec <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103eb8:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103ebd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ec2:	77 20                	ja     f0103ee4 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ec4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ec8:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0103ecf:	f0 
f0103ed0:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
f0103ed7:	00 
f0103ed8:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f0103edf:	e8 5c c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ee4:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ee9:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103eec:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103eef:	e8 15 2d 00 00       	call   f0106c09 <cpunum>
f0103ef4:	6b d0 74             	imul   $0x74,%eax,%edx
f0103ef7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103efc:	83 ba 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%edx)
f0103f03:	74 11                	je     f0103f16 <env_free+0x7a>
f0103f05:	e8 ff 2c 00 00       	call   f0106c09 <cpunum>
f0103f0a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f0d:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0103f13:	8b 40 48             	mov    0x48(%eax),%eax
f0103f16:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f1e:	c7 04 24 57 89 10 f0 	movl   $0xf0108957,(%esp)
f0103f25:	e8 26 04 00 00       	call   f0104350 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103f2a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103f31:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f34:	89 c8                	mov    %ecx,%eax
f0103f36:	c1 e0 02             	shl    $0x2,%eax
f0103f39:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103f3c:	8b 47 60             	mov    0x60(%edi),%eax
f0103f3f:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103f42:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103f48:	0f 84 b7 00 00 00    	je     f0104005 <env_free+0x169>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103f4e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103f54:	89 f0                	mov    %esi,%eax
f0103f56:	c1 e8 0c             	shr    $0xc,%eax
f0103f59:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f5c:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0103f62:	72 20                	jb     f0103f84 <env_free+0xe8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103f64:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103f68:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0103f6f:	f0 
f0103f70:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
f0103f77:	00 
f0103f78:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f0103f7f:	e8 bc c0 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103f84:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f87:	c1 e0 16             	shl    $0x16,%eax
f0103f8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103f8d:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103f92:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103f99:	01 
f0103f9a:	74 17                	je     f0103fb3 <env_free+0x117>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103f9c:	89 d8                	mov    %ebx,%eax
f0103f9e:	c1 e0 0c             	shl    $0xc,%eax
f0103fa1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fa8:	8b 47 60             	mov    0x60(%edi),%eax
f0103fab:	89 04 24             	mov    %eax,(%esp)
f0103fae:	e8 ff d7 ff ff       	call   f01017b2 <page_remove>
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103fb3:	83 c3 01             	add    $0x1,%ebx
f0103fb6:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103fbc:	75 d4                	jne    f0103f92 <env_free+0xf6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103fbe:	8b 47 60             	mov    0x60(%edi),%eax
f0103fc1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103fc4:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103fcb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103fce:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0103fd4:	72 1c                	jb     f0103ff2 <env_free+0x156>
		panic("pa2page called with invalid pa");
f0103fd6:	c7 44 24 08 60 80 10 	movl   $0xf0108060,0x8(%esp)
f0103fdd:	f0 
f0103fde:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103fe5:	00 
f0103fe6:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f0103fed:	e8 4e c0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103ff2:	a1 90 1e 23 f0       	mov    0xf0231e90,%eax
f0103ff7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103ffa:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103ffd:	89 04 24             	mov    %eax,(%esp)
f0104000:	e8 70 d5 ff ff       	call   f0101575 <page_decref>
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104005:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0104009:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0104010:	0f 85 1b ff ff ff    	jne    f0103f31 <env_free+0x95>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0104016:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0104019:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010401e:	77 20                	ja     f0104040 <env_free+0x1a4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104020:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104024:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f010402b:	f0 
f010402c:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
f0104033:	00 
f0104034:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f010403b:	e8 00 c0 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0104040:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0104047:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f010404c:	c1 e8 0c             	shr    $0xc,%eax
f010404f:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f0104055:	72 1c                	jb     f0104073 <env_free+0x1d7>
		panic("pa2page called with invalid pa");
f0104057:	c7 44 24 08 60 80 10 	movl   $0xf0108060,0x8(%esp)
f010405e:	f0 
f010405f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0104066:	00 
f0104067:	c7 04 24 fb 7b 10 f0 	movl   $0xf0107bfb,(%esp)
f010406e:	e8 cd bf ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0104073:	8b 15 90 1e 23 f0    	mov    0xf0231e90,%edx
f0104079:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f010407c:	89 04 24             	mov    %eax,(%esp)
f010407f:	e8 f1 d4 ff ff       	call   f0101575 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104084:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010408b:	a1 4c 12 23 f0       	mov    0xf023124c,%eax
f0104090:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0104093:	89 3d 4c 12 23 f0    	mov    %edi,0xf023124c
}
f0104099:	83 c4 2c             	add    $0x2c,%esp
f010409c:	5b                   	pop    %ebx
f010409d:	5e                   	pop    %esi
f010409e:	5f                   	pop    %edi
f010409f:	5d                   	pop    %ebp
f01040a0:	c3                   	ret    

f01040a1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01040a1:	55                   	push   %ebp
f01040a2:	89 e5                	mov    %esp,%ebp
f01040a4:	53                   	push   %ebx
f01040a5:	83 ec 14             	sub    $0x14,%esp
f01040a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01040ab:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01040af:	75 19                	jne    f01040ca <env_destroy+0x29>
f01040b1:	e8 53 2b 00 00       	call   f0106c09 <cpunum>
f01040b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b9:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f01040bf:	74 09                	je     f01040ca <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01040c1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01040c8:	eb 2f                	jmp    f01040f9 <env_destroy+0x58>
	}

	env_free(e);
f01040ca:	89 1c 24             	mov    %ebx,(%esp)
f01040cd:	e8 ca fd ff ff       	call   f0103e9c <env_free>

	if (curenv == e) {
f01040d2:	e8 32 2b 00 00       	call   f0106c09 <cpunum>
f01040d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040da:	39 98 28 20 23 f0    	cmp    %ebx,-0xfdcdfd8(%eax)
f01040e0:	75 17                	jne    f01040f9 <env_destroy+0x58>
		curenv = NULL;
f01040e2:	e8 22 2b 00 00       	call   f0106c09 <cpunum>
f01040e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ea:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f01040f1:	00 00 00 
		sched_yield();
f01040f4:	e8 69 11 00 00       	call   f0105262 <sched_yield>
	}
}
f01040f9:	83 c4 14             	add    $0x14,%esp
f01040fc:	5b                   	pop    %ebx
f01040fd:	5d                   	pop    %ebp
f01040fe:	c3                   	ret    

f01040ff <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01040ff:	55                   	push   %ebp
f0104100:	89 e5                	mov    %esp,%ebp
f0104102:	53                   	push   %ebx
f0104103:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0104106:	e8 fe 2a 00 00       	call   f0106c09 <cpunum>
f010410b:	6b c0 74             	imul   $0x74,%eax,%eax
f010410e:	8b 98 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%ebx
f0104114:	e8 f0 2a 00 00       	call   f0106c09 <cpunum>
f0104119:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010411c:	8b 65 08             	mov    0x8(%ebp),%esp
f010411f:	61                   	popa   
f0104120:	07                   	pop    %es
f0104121:	1f                   	pop    %ds
f0104122:	83 c4 08             	add    $0x8,%esp
f0104125:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104126:	c7 44 24 08 6d 89 10 	movl   $0xf010896d,0x8(%esp)
f010412d:	f0 
f010412e:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
f0104135:	00 
f0104136:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f010413d:	e8 fe be ff ff       	call   f0100040 <_panic>

f0104142 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104142:	55                   	push   %ebp
f0104143:	89 e5                	mov    %esp,%ebp
f0104145:	53                   	push   %ebx
f0104146:	83 ec 14             	sub    $0x14,%esp
f0104149:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if ( curenv != NULL )
f010414c:	e8 b8 2a 00 00       	call   f0106c09 <cpunum>
f0104151:	6b c0 74             	imul   $0x74,%eax,%eax
f0104154:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f010415b:	74 29                	je     f0104186 <env_run+0x44>
	{
		if ( curenv->env_status == ENV_RUNNING )
f010415d:	e8 a7 2a 00 00       	call   f0106c09 <cpunum>
f0104162:	6b c0 74             	imul   $0x74,%eax,%eax
f0104165:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010416b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010416f:	75 15                	jne    f0104186 <env_run+0x44>
		{
			curenv->env_status = ENV_RUNNABLE;
f0104171:	e8 93 2a 00 00       	call   f0106c09 <cpunum>
f0104176:	6b c0 74             	imul   $0x74,%eax,%eax
f0104179:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010417f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
	}

	curenv = e;
f0104186:	e8 7e 2a 00 00       	call   f0106c09 <cpunum>
f010418b:	6b c0 74             	imul   $0x74,%eax,%eax
f010418e:	89 98 28 20 23 f0    	mov    %ebx,-0xfdcdfd8(%eax)
	e->env_status = ENV_RUNNING;
f0104194:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f010419b:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f010419f:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01041a2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01041a7:	77 20                	ja     f01041c9 <env_run+0x87>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01041a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041ad:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f01041b4:	f0 
f01041b5:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
f01041bc:	00 
f01041bd:	c7 04 24 df 88 10 f0 	movl   $0xf01088df,(%esp)
f01041c4:	e8 77 be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01041c9:	05 00 00 00 10       	add    $0x10000000,%eax
f01041ce:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01041d1:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01041d8:	e8 56 2d 00 00       	call   f0106f33 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01041dd:	f3 90                	pause  
	
	unlock_kernel();
	env_pop_tf(&(e->env_tf));
f01041df:	89 1c 24             	mov    %ebx,(%esp)
f01041e2:	e8 18 ff ff ff       	call   f01040ff <env_pop_tf>

f01041e7 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01041e7:	55                   	push   %ebp
f01041e8:	89 e5                	mov    %esp,%ebp
f01041ea:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01041ee:	ba 70 00 00 00       	mov    $0x70,%edx
f01041f3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01041f4:	b2 71                	mov    $0x71,%dl
f01041f6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01041f7:	0f b6 c0             	movzbl %al,%eax
}
f01041fa:	5d                   	pop    %ebp
f01041fb:	c3                   	ret    

f01041fc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01041fc:	55                   	push   %ebp
f01041fd:	89 e5                	mov    %esp,%ebp
f01041ff:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104203:	ba 70 00 00 00       	mov    $0x70,%edx
f0104208:	ee                   	out    %al,(%dx)
f0104209:	b2 71                	mov    $0x71,%dl
f010420b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010420e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010420f:	5d                   	pop    %ebp
f0104210:	c3                   	ret    

f0104211 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0104211:	55                   	push   %ebp
f0104212:	89 e5                	mov    %esp,%ebp
f0104214:	56                   	push   %esi
f0104215:	53                   	push   %ebx
f0104216:	83 ec 10             	sub    $0x10,%esp
f0104219:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010421c:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0104222:	80 3d 50 12 23 f0 00 	cmpb   $0x0,0xf0231250
f0104229:	74 4e                	je     f0104279 <irq_setmask_8259A+0x68>
f010422b:	89 c6                	mov    %eax,%esi
f010422d:	ba 21 00 00 00       	mov    $0x21,%edx
f0104232:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0104233:	66 c1 e8 08          	shr    $0x8,%ax
f0104237:	b2 a1                	mov    $0xa1,%dl
f0104239:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f010423a:	c7 04 24 79 89 10 f0 	movl   $0xf0108979,(%esp)
f0104241:	e8 0a 01 00 00       	call   f0104350 <cprintf>
	for (i = 0; i < 16; i++)
f0104246:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010424b:	0f b7 f6             	movzwl %si,%esi
f010424e:	f7 d6                	not    %esi
f0104250:	0f a3 de             	bt     %ebx,%esi
f0104253:	73 10                	jae    f0104265 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0104255:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104259:	c7 04 24 5b 8e 10 f0 	movl   $0xf0108e5b,(%esp)
f0104260:	e8 eb 00 00 00       	call   f0104350 <cprintf>
	for (i = 0; i < 16; i++)
f0104265:	83 c3 01             	add    $0x1,%ebx
f0104268:	83 fb 10             	cmp    $0x10,%ebx
f010426b:	75 e3                	jne    f0104250 <irq_setmask_8259A+0x3f>
	cprintf("\n");
f010426d:	c7 04 24 30 76 10 f0 	movl   $0xf0107630,(%esp)
f0104274:	e8 d7 00 00 00       	call   f0104350 <cprintf>
}
f0104279:	83 c4 10             	add    $0x10,%esp
f010427c:	5b                   	pop    %ebx
f010427d:	5e                   	pop    %esi
f010427e:	5d                   	pop    %ebp
f010427f:	c3                   	ret    

f0104280 <pic_init>:
	didinit = 1;
f0104280:	c6 05 50 12 23 f0 01 	movb   $0x1,0xf0231250
f0104287:	ba 21 00 00 00       	mov    $0x21,%edx
f010428c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104291:	ee                   	out    %al,(%dx)
f0104292:	b2 a1                	mov    $0xa1,%dl
f0104294:	ee                   	out    %al,(%dx)
f0104295:	b2 20                	mov    $0x20,%dl
f0104297:	b8 11 00 00 00       	mov    $0x11,%eax
f010429c:	ee                   	out    %al,(%dx)
f010429d:	b2 21                	mov    $0x21,%dl
f010429f:	b8 20 00 00 00       	mov    $0x20,%eax
f01042a4:	ee                   	out    %al,(%dx)
f01042a5:	b8 04 00 00 00       	mov    $0x4,%eax
f01042aa:	ee                   	out    %al,(%dx)
f01042ab:	b8 03 00 00 00       	mov    $0x3,%eax
f01042b0:	ee                   	out    %al,(%dx)
f01042b1:	b2 a0                	mov    $0xa0,%dl
f01042b3:	b8 11 00 00 00       	mov    $0x11,%eax
f01042b8:	ee                   	out    %al,(%dx)
f01042b9:	b2 a1                	mov    $0xa1,%dl
f01042bb:	b8 28 00 00 00       	mov    $0x28,%eax
f01042c0:	ee                   	out    %al,(%dx)
f01042c1:	b8 02 00 00 00       	mov    $0x2,%eax
f01042c6:	ee                   	out    %al,(%dx)
f01042c7:	b8 01 00 00 00       	mov    $0x1,%eax
f01042cc:	ee                   	out    %al,(%dx)
f01042cd:	b2 20                	mov    $0x20,%dl
f01042cf:	b8 68 00 00 00       	mov    $0x68,%eax
f01042d4:	ee                   	out    %al,(%dx)
f01042d5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01042da:	ee                   	out    %al,(%dx)
f01042db:	b2 a0                	mov    $0xa0,%dl
f01042dd:	b8 68 00 00 00       	mov    $0x68,%eax
f01042e2:	ee                   	out    %al,(%dx)
f01042e3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01042e8:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f01042e9:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01042f0:	66 83 f8 ff          	cmp    $0xffff,%ax
f01042f4:	74 12                	je     f0104308 <pic_init+0x88>
{
f01042f6:	55                   	push   %ebp
f01042f7:	89 e5                	mov    %esp,%ebp
f01042f9:	83 ec 18             	sub    $0x18,%esp
		irq_setmask_8259A(irq_mask_8259A);
f01042fc:	0f b7 c0             	movzwl %ax,%eax
f01042ff:	89 04 24             	mov    %eax,(%esp)
f0104302:	e8 0a ff ff ff       	call   f0104211 <irq_setmask_8259A>
}
f0104307:	c9                   	leave  
f0104308:	f3 c3                	repz ret 

f010430a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010430a:	55                   	push   %ebp
f010430b:	89 e5                	mov    %esp,%ebp
f010430d:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104310:	8b 45 08             	mov    0x8(%ebp),%eax
f0104313:	89 04 24             	mov    %eax,(%esp)
f0104316:	e8 5f c4 ff ff       	call   f010077a <cputchar>
	*cnt++;
}
f010431b:	c9                   	leave  
f010431c:	c3                   	ret    

f010431d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010431d:	55                   	push   %ebp
f010431e:	89 e5                	mov    %esp,%ebp
f0104320:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104323:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010432a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010432d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104331:	8b 45 08             	mov    0x8(%ebp),%eax
f0104334:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104338:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010433b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010433f:	c7 04 24 0a 43 10 f0 	movl   $0xf010430a,(%esp)
f0104346:	e8 b3 1b 00 00       	call   f0105efe <vprintfmt>
	return cnt;
}
f010434b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010434e:	c9                   	leave  
f010434f:	c3                   	ret    

f0104350 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104350:	55                   	push   %ebp
f0104351:	89 e5                	mov    %esp,%ebp
f0104353:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104356:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104359:	89 44 24 04          	mov    %eax,0x4(%esp)
f010435d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104360:	89 04 24             	mov    %eax,(%esp)
f0104363:	e8 b5 ff ff ff       	call   f010431d <vcprintf>
	va_end(ap);

	return cnt;
}
f0104368:	c9                   	leave  
f0104369:	c3                   	ret    
f010436a:	66 90                	xchg   %ax,%ax
f010436c:	66 90                	xchg   %ax,%ax
f010436e:	66 90                	xchg   %ax,%ax

f0104370 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104370:	55                   	push   %ebp
f0104371:	89 e5                	mov    %esp,%ebp
f0104373:	57                   	push   %edi
f0104374:	56                   	push   %esi
f0104375:	53                   	push   %ebx
f0104376:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) percpu_kstacks[cpunum()];
f0104379:	e8 8b 28 00 00       	call   f0106c09 <cpunum>
f010437e:	89 c3                	mov    %eax,%ebx
f0104380:	e8 84 28 00 00       	call   f0106c09 <cpunum>
f0104385:	6b db 74             	imul   $0x74,%ebx,%ebx
f0104388:	c1 e0 0f             	shl    $0xf,%eax
f010438b:	05 00 30 23 f0       	add    $0xf0233000,%eax
f0104390:	89 83 30 20 23 f0    	mov    %eax,-0xfdcdfd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104396:	e8 6e 28 00 00       	call   f0106c09 <cpunum>
f010439b:	6b c0 74             	imul   $0x74,%eax,%eax
f010439e:	66 c7 80 34 20 23 f0 	movw   $0x10,-0xfdcdfcc(%eax)
f01043a5:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01043a7:	e8 5d 28 00 00       	call   f0106c09 <cpunum>
f01043ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01043af:	66 c7 80 92 20 23 f0 	movw   $0x68,-0xfdcdf6e(%eax)
f01043b6:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01043b8:	e8 4c 28 00 00       	call   f0106c09 <cpunum>
f01043bd:	8d 58 05             	lea    0x5(%eax),%ebx
f01043c0:	e8 44 28 00 00       	call   f0106c09 <cpunum>
f01043c5:	89 c7                	mov    %eax,%edi
f01043c7:	e8 3d 28 00 00       	call   f0106c09 <cpunum>
f01043cc:	89 c6                	mov    %eax,%esi
f01043ce:	e8 36 28 00 00       	call   f0106c09 <cpunum>
f01043d3:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f01043da:	f0 67 00 
f01043dd:	6b ff 74             	imul   $0x74,%edi,%edi
f01043e0:	81 c7 2c 20 23 f0    	add    $0xf023202c,%edi
f01043e6:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f01043ed:	f0 
f01043ee:	6b d6 74             	imul   $0x74,%esi,%edx
f01043f1:	81 c2 2c 20 23 f0    	add    $0xf023202c,%edx
f01043f7:	c1 ea 10             	shr    $0x10,%edx
f01043fa:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0104401:	c6 04 dd 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%ebx,8)
f0104408:	99 
f0104409:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0104410:	40 
f0104411:	6b c0 74             	imul   $0x74,%eax,%eax
f0104414:	05 2c 20 23 f0       	add    $0xf023202c,%eax
f0104419:	c1 e8 18             	shr    $0x18,%eax
f010441c:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0104423:	e8 e1 27 00 00       	call   f0106c09 <cpunum>
f0104428:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f010442f:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0104430:	e8 d4 27 00 00       	call   f0106c09 <cpunum>
f0104435:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f010443c:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f010443f:	b8 aa 23 12 f0       	mov    $0xf01223aa,%eax
f0104444:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0104447:	83 c4 0c             	add    $0xc,%esp
f010444a:	5b                   	pop    %ebx
f010444b:	5e                   	pop    %esi
f010444c:	5f                   	pop    %edi
f010444d:	5d                   	pop    %ebp
f010444e:	c3                   	ret    

f010444f <trap_init>:
{
f010444f:	55                   	push   %ebp
f0104450:	89 e5                	mov    %esp,%ebp
f0104452:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0104455:	b8 82 50 10 f0       	mov    $0xf0105082,%eax
f010445a:	66 a3 60 12 23 f0    	mov    %ax,0xf0231260
f0104460:	66 c7 05 62 12 23 f0 	movw   $0x8,0xf0231262
f0104467:	08 00 
f0104469:	c6 05 64 12 23 f0 00 	movb   $0x0,0xf0231264
f0104470:	c6 05 65 12 23 f0 8e 	movb   $0x8e,0xf0231265
f0104477:	c1 e8 10             	shr    $0x10,%eax
f010447a:	66 a3 66 12 23 f0    	mov    %ax,0xf0231266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0104480:	b8 8c 50 10 f0       	mov    $0xf010508c,%eax
f0104485:	66 a3 68 12 23 f0    	mov    %ax,0xf0231268
f010448b:	66 c7 05 6a 12 23 f0 	movw   $0x8,0xf023126a
f0104492:	08 00 
f0104494:	c6 05 6c 12 23 f0 00 	movb   $0x0,0xf023126c
f010449b:	c6 05 6d 12 23 f0 8e 	movb   $0x8e,0xf023126d
f01044a2:	c1 e8 10             	shr    $0x10,%eax
f01044a5:	66 a3 6e 12 23 f0    	mov    %ax,0xf023126e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);	
f01044ab:	b8 96 50 10 f0       	mov    $0xf0105096,%eax
f01044b0:	66 a3 70 12 23 f0    	mov    %ax,0xf0231270
f01044b6:	66 c7 05 72 12 23 f0 	movw   $0x8,0xf0231272
f01044bd:	08 00 
f01044bf:	c6 05 74 12 23 f0 00 	movb   $0x0,0xf0231274
f01044c6:	c6 05 75 12 23 f0 8e 	movb   $0x8e,0xf0231275
f01044cd:	c1 e8 10             	shr    $0x10,%eax
f01044d0:	66 a3 76 12 23 f0    	mov    %ax,0xf0231276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01044d6:	b8 a0 50 10 f0       	mov    $0xf01050a0,%eax
f01044db:	66 a3 78 12 23 f0    	mov    %ax,0xf0231278
f01044e1:	66 c7 05 7a 12 23 f0 	movw   $0x8,0xf023127a
f01044e8:	08 00 
f01044ea:	c6 05 7c 12 23 f0 00 	movb   $0x0,0xf023127c
f01044f1:	c6 05 7d 12 23 f0 ee 	movb   $0xee,0xf023127d
f01044f8:	c1 e8 10             	shr    $0x10,%eax
f01044fb:	66 a3 7e 12 23 f0    	mov    %ax,0xf023127e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0104501:	b8 aa 50 10 f0       	mov    $0xf01050aa,%eax
f0104506:	66 a3 80 12 23 f0    	mov    %ax,0xf0231280
f010450c:	66 c7 05 82 12 23 f0 	movw   $0x8,0xf0231282
f0104513:	08 00 
f0104515:	c6 05 84 12 23 f0 00 	movb   $0x0,0xf0231284
f010451c:	c6 05 85 12 23 f0 8e 	movb   $0x8e,0xf0231285
f0104523:	c1 e8 10             	shr    $0x10,%eax
f0104526:	66 a3 86 12 23 f0    	mov    %ax,0xf0231286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f010452c:	b8 b4 50 10 f0       	mov    $0xf01050b4,%eax
f0104531:	66 a3 88 12 23 f0    	mov    %ax,0xf0231288
f0104537:	66 c7 05 8a 12 23 f0 	movw   $0x8,0xf023128a
f010453e:	08 00 
f0104540:	c6 05 8c 12 23 f0 00 	movb   $0x0,0xf023128c
f0104547:	c6 05 8d 12 23 f0 8e 	movb   $0x8e,0xf023128d
f010454e:	c1 e8 10             	shr    $0x10,%eax
f0104551:	66 a3 8e 12 23 f0    	mov    %ax,0xf023128e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0104557:	b8 be 50 10 f0       	mov    $0xf01050be,%eax
f010455c:	66 a3 90 12 23 f0    	mov    %ax,0xf0231290
f0104562:	66 c7 05 92 12 23 f0 	movw   $0x8,0xf0231292
f0104569:	08 00 
f010456b:	c6 05 94 12 23 f0 00 	movb   $0x0,0xf0231294
f0104572:	c6 05 95 12 23 f0 8e 	movb   $0x8e,0xf0231295
f0104579:	c1 e8 10             	shr    $0x10,%eax
f010457c:	66 a3 96 12 23 f0    	mov    %ax,0xf0231296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0104582:	b8 c8 50 10 f0       	mov    $0xf01050c8,%eax
f0104587:	66 a3 98 12 23 f0    	mov    %ax,0xf0231298
f010458d:	66 c7 05 9a 12 23 f0 	movw   $0x8,0xf023129a
f0104594:	08 00 
f0104596:	c6 05 9c 12 23 f0 00 	movb   $0x0,0xf023129c
f010459d:	c6 05 9d 12 23 f0 8e 	movb   $0x8e,0xf023129d
f01045a4:	c1 e8 10             	shr    $0x10,%eax
f01045a7:	66 a3 9e 12 23 f0    	mov    %ax,0xf023129e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f01045ad:	b8 d2 50 10 f0       	mov    $0xf01050d2,%eax
f01045b2:	66 a3 a0 12 23 f0    	mov    %ax,0xf02312a0
f01045b8:	66 c7 05 a2 12 23 f0 	movw   $0x8,0xf02312a2
f01045bf:	08 00 
f01045c1:	c6 05 a4 12 23 f0 00 	movb   $0x0,0xf02312a4
f01045c8:	c6 05 a5 12 23 f0 8e 	movb   $0x8e,0xf02312a5
f01045cf:	c1 e8 10             	shr    $0x10,%eax
f01045d2:	66 a3 a6 12 23 f0    	mov    %ax,0xf02312a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f01045d8:	b8 da 50 10 f0       	mov    $0xf01050da,%eax
f01045dd:	66 a3 b0 12 23 f0    	mov    %ax,0xf02312b0
f01045e3:	66 c7 05 b2 12 23 f0 	movw   $0x8,0xf02312b2
f01045ea:	08 00 
f01045ec:	c6 05 b4 12 23 f0 00 	movb   $0x0,0xf02312b4
f01045f3:	c6 05 b5 12 23 f0 8e 	movb   $0x8e,0xf02312b5
f01045fa:	c1 e8 10             	shr    $0x10,%eax
f01045fd:	66 a3 b6 12 23 f0    	mov    %ax,0xf02312b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0104603:	b8 e2 50 10 f0       	mov    $0xf01050e2,%eax
f0104608:	66 a3 b8 12 23 f0    	mov    %ax,0xf02312b8
f010460e:	66 c7 05 ba 12 23 f0 	movw   $0x8,0xf02312ba
f0104615:	08 00 
f0104617:	c6 05 bc 12 23 f0 00 	movb   $0x0,0xf02312bc
f010461e:	c6 05 bd 12 23 f0 8e 	movb   $0x8e,0xf02312bd
f0104625:	c1 e8 10             	shr    $0x10,%eax
f0104628:	66 a3 be 12 23 f0    	mov    %ax,0xf02312be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f010462e:	b8 ea 50 10 f0       	mov    $0xf01050ea,%eax
f0104633:	66 a3 c0 12 23 f0    	mov    %ax,0xf02312c0
f0104639:	66 c7 05 c2 12 23 f0 	movw   $0x8,0xf02312c2
f0104640:	08 00 
f0104642:	c6 05 c4 12 23 f0 00 	movb   $0x0,0xf02312c4
f0104649:	c6 05 c5 12 23 f0 8e 	movb   $0x8e,0xf02312c5
f0104650:	c1 e8 10             	shr    $0x10,%eax
f0104653:	66 a3 c6 12 23 f0    	mov    %ax,0xf02312c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0104659:	b8 f2 50 10 f0       	mov    $0xf01050f2,%eax
f010465e:	66 a3 c8 12 23 f0    	mov    %ax,0xf02312c8
f0104664:	66 c7 05 ca 12 23 f0 	movw   $0x8,0xf02312ca
f010466b:	08 00 
f010466d:	c6 05 cc 12 23 f0 00 	movb   $0x0,0xf02312cc
f0104674:	c6 05 cd 12 23 f0 8e 	movb   $0x8e,0xf02312cd
f010467b:	c1 e8 10             	shr    $0x10,%eax
f010467e:	66 a3 ce 12 23 f0    	mov    %ax,0xf02312ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0104684:	b8 fa 50 10 f0       	mov    $0xf01050fa,%eax
f0104689:	66 a3 d0 12 23 f0    	mov    %ax,0xf02312d0
f010468f:	66 c7 05 d2 12 23 f0 	movw   $0x8,0xf02312d2
f0104696:	08 00 
f0104698:	c6 05 d4 12 23 f0 00 	movb   $0x0,0xf02312d4
f010469f:	c6 05 d5 12 23 f0 8e 	movb   $0x8e,0xf02312d5
f01046a6:	c1 e8 10             	shr    $0x10,%eax
f01046a9:	66 a3 d6 12 23 f0    	mov    %ax,0xf02312d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f01046af:	b8 fe 50 10 f0       	mov    $0xf01050fe,%eax
f01046b4:	66 a3 e0 12 23 f0    	mov    %ax,0xf02312e0
f01046ba:	66 c7 05 e2 12 23 f0 	movw   $0x8,0xf02312e2
f01046c1:	08 00 
f01046c3:	c6 05 e4 12 23 f0 00 	movb   $0x0,0xf02312e4
f01046ca:	c6 05 e5 12 23 f0 8e 	movb   $0x8e,0xf02312e5
f01046d1:	c1 e8 10             	shr    $0x10,%eax
f01046d4:	66 a3 e6 12 23 f0    	mov    %ax,0xf02312e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f01046da:	b8 04 51 10 f0       	mov    $0xf0105104,%eax
f01046df:	66 a3 e8 12 23 f0    	mov    %ax,0xf02312e8
f01046e5:	66 c7 05 ea 12 23 f0 	movw   $0x8,0xf02312ea
f01046ec:	08 00 
f01046ee:	c6 05 ec 12 23 f0 00 	movb   $0x0,0xf02312ec
f01046f5:	c6 05 ed 12 23 f0 8e 	movb   $0x8e,0xf02312ed
f01046fc:	c1 e8 10             	shr    $0x10,%eax
f01046ff:	66 a3 ee 12 23 f0    	mov    %ax,0xf02312ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0104705:	b8 08 51 10 f0       	mov    $0xf0105108,%eax
f010470a:	66 a3 f0 12 23 f0    	mov    %ax,0xf02312f0
f0104710:	66 c7 05 f2 12 23 f0 	movw   $0x8,0xf02312f2
f0104717:	08 00 
f0104719:	c6 05 f4 12 23 f0 00 	movb   $0x0,0xf02312f4
f0104720:	c6 05 f5 12 23 f0 8e 	movb   $0x8e,0xf02312f5
f0104727:	c1 e8 10             	shr    $0x10,%eax
f010472a:	66 a3 f6 12 23 f0    	mov    %ax,0xf02312f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0104730:	b8 0e 51 10 f0       	mov    $0xf010510e,%eax
f0104735:	66 a3 f8 12 23 f0    	mov    %ax,0xf02312f8
f010473b:	66 c7 05 fa 12 23 f0 	movw   $0x8,0xf02312fa
f0104742:	08 00 
f0104744:	c6 05 fc 12 23 f0 00 	movb   $0x0,0xf02312fc
f010474b:	c6 05 fd 12 23 f0 8e 	movb   $0x8e,0xf02312fd
f0104752:	c1 e8 10             	shr    $0x10,%eax
f0104755:	66 a3 fe 12 23 f0    	mov    %ax,0xf02312fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f010475b:	b8 14 51 10 f0       	mov    $0xf0105114,%eax
f0104760:	66 a3 e0 13 23 f0    	mov    %ax,0xf02313e0
f0104766:	66 c7 05 e2 13 23 f0 	movw   $0x8,0xf02313e2
f010476d:	08 00 
f010476f:	c6 05 e4 13 23 f0 00 	movb   $0x0,0xf02313e4
f0104776:	c6 05 e5 13 23 f0 ee 	movb   $0xee,0xf02313e5
f010477d:	c1 e8 10             	shr    $0x10,%eax
f0104780:	66 a3 e6 13 23 f0    	mov    %ax,0xf02313e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, t_irq_timer, 0);
f0104786:	b8 1a 51 10 f0       	mov    $0xf010511a,%eax
f010478b:	66 a3 60 13 23 f0    	mov    %ax,0xf0231360
f0104791:	66 c7 05 62 13 23 f0 	movw   $0x8,0xf0231362
f0104798:	08 00 
f010479a:	c6 05 64 13 23 f0 00 	movb   $0x0,0xf0231364
f01047a1:	c6 05 65 13 23 f0 8e 	movb   $0x8e,0xf0231365
f01047a8:	c1 e8 10             	shr    $0x10,%eax
f01047ab:	66 a3 66 13 23 f0    	mov    %ax,0xf0231366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, t_irq_kbd, 0);
f01047b1:	b8 20 51 10 f0       	mov    $0xf0105120,%eax
f01047b6:	66 a3 68 13 23 f0    	mov    %ax,0xf0231368
f01047bc:	66 c7 05 6a 13 23 f0 	movw   $0x8,0xf023136a
f01047c3:	08 00 
f01047c5:	c6 05 6c 13 23 f0 00 	movb   $0x0,0xf023136c
f01047cc:	c6 05 6d 13 23 f0 8e 	movb   $0x8e,0xf023136d
f01047d3:	c1 e8 10             	shr    $0x10,%eax
f01047d6:	66 a3 6e 13 23 f0    	mov    %ax,0xf023136e
	SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, t_irq_2, 0);
f01047dc:	b8 26 51 10 f0       	mov    $0xf0105126,%eax
f01047e1:	66 a3 70 13 23 f0    	mov    %ax,0xf0231370
f01047e7:	66 c7 05 72 13 23 f0 	movw   $0x8,0xf0231372
f01047ee:	08 00 
f01047f0:	c6 05 74 13 23 f0 00 	movb   $0x0,0xf0231374
f01047f7:	c6 05 75 13 23 f0 8e 	movb   $0x8e,0xf0231375
f01047fe:	c1 e8 10             	shr    $0x10,%eax
f0104801:	66 a3 76 13 23 f0    	mov    %ax,0xf0231376
	SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, t_irq_3, 0);
f0104807:	b8 2c 51 10 f0       	mov    $0xf010512c,%eax
f010480c:	66 a3 78 13 23 f0    	mov    %ax,0xf0231378
f0104812:	66 c7 05 7a 13 23 f0 	movw   $0x8,0xf023137a
f0104819:	08 00 
f010481b:	c6 05 7c 13 23 f0 00 	movb   $0x0,0xf023137c
f0104822:	c6 05 7d 13 23 f0 8e 	movb   $0x8e,0xf023137d
f0104829:	c1 e8 10             	shr    $0x10,%eax
f010482c:	66 a3 7e 13 23 f0    	mov    %ax,0xf023137e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, t_irq_serial, 0);
f0104832:	b8 32 51 10 f0       	mov    $0xf0105132,%eax
f0104837:	66 a3 80 13 23 f0    	mov    %ax,0xf0231380
f010483d:	66 c7 05 82 13 23 f0 	movw   $0x8,0xf0231382
f0104844:	08 00 
f0104846:	c6 05 84 13 23 f0 00 	movb   $0x0,0xf0231384
f010484d:	c6 05 85 13 23 f0 8e 	movb   $0x8e,0xf0231385
f0104854:	c1 e8 10             	shr    $0x10,%eax
f0104857:	66 a3 86 13 23 f0    	mov    %ax,0xf0231386
	SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, t_irq_5, 0);
f010485d:	b8 38 51 10 f0       	mov    $0xf0105138,%eax
f0104862:	66 a3 88 13 23 f0    	mov    %ax,0xf0231388
f0104868:	66 c7 05 8a 13 23 f0 	movw   $0x8,0xf023138a
f010486f:	08 00 
f0104871:	c6 05 8c 13 23 f0 00 	movb   $0x0,0xf023138c
f0104878:	c6 05 8d 13 23 f0 8e 	movb   $0x8e,0xf023138d
f010487f:	c1 e8 10             	shr    $0x10,%eax
f0104882:	66 a3 8e 13 23 f0    	mov    %ax,0xf023138e
	SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, t_irq_6, 0);
f0104888:	b8 3e 51 10 f0       	mov    $0xf010513e,%eax
f010488d:	66 a3 90 13 23 f0    	mov    %ax,0xf0231390
f0104893:	66 c7 05 92 13 23 f0 	movw   $0x8,0xf0231392
f010489a:	08 00 
f010489c:	c6 05 94 13 23 f0 00 	movb   $0x0,0xf0231394
f01048a3:	c6 05 95 13 23 f0 8e 	movb   $0x8e,0xf0231395
f01048aa:	c1 e8 10             	shr    $0x10,%eax
f01048ad:	66 a3 96 13 23 f0    	mov    %ax,0xf0231396
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, t_irq_spurious, 0);	
f01048b3:	b8 44 51 10 f0       	mov    $0xf0105144,%eax
f01048b8:	66 a3 98 13 23 f0    	mov    %ax,0xf0231398
f01048be:	66 c7 05 9a 13 23 f0 	movw   $0x8,0xf023139a
f01048c5:	08 00 
f01048c7:	c6 05 9c 13 23 f0 00 	movb   $0x0,0xf023139c
f01048ce:	c6 05 9d 13 23 f0 8e 	movb   $0x8e,0xf023139d
f01048d5:	c1 e8 10             	shr    $0x10,%eax
f01048d8:	66 a3 9e 13 23 f0    	mov    %ax,0xf023139e
	SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, t_irq_8, 0);
f01048de:	b8 4a 51 10 f0       	mov    $0xf010514a,%eax
f01048e3:	66 a3 a0 13 23 f0    	mov    %ax,0xf02313a0
f01048e9:	66 c7 05 a2 13 23 f0 	movw   $0x8,0xf02313a2
f01048f0:	08 00 
f01048f2:	c6 05 a4 13 23 f0 00 	movb   $0x0,0xf02313a4
f01048f9:	c6 05 a5 13 23 f0 8e 	movb   $0x8e,0xf02313a5
f0104900:	c1 e8 10             	shr    $0x10,%eax
f0104903:	66 a3 a6 13 23 f0    	mov    %ax,0xf02313a6
	SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, t_irq_9, 0);
f0104909:	b8 50 51 10 f0       	mov    $0xf0105150,%eax
f010490e:	66 a3 a8 13 23 f0    	mov    %ax,0xf02313a8
f0104914:	66 c7 05 aa 13 23 f0 	movw   $0x8,0xf02313aa
f010491b:	08 00 
f010491d:	c6 05 ac 13 23 f0 00 	movb   $0x0,0xf02313ac
f0104924:	c6 05 ad 13 23 f0 8e 	movb   $0x8e,0xf02313ad
f010492b:	c1 e8 10             	shr    $0x10,%eax
f010492e:	66 a3 ae 13 23 f0    	mov    %ax,0xf02313ae
	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, t_irq_10, 0);
f0104934:	b8 56 51 10 f0       	mov    $0xf0105156,%eax
f0104939:	66 a3 b0 13 23 f0    	mov    %ax,0xf02313b0
f010493f:	66 c7 05 b2 13 23 f0 	movw   $0x8,0xf02313b2
f0104946:	08 00 
f0104948:	c6 05 b4 13 23 f0 00 	movb   $0x0,0xf02313b4
f010494f:	c6 05 b5 13 23 f0 8e 	movb   $0x8e,0xf02313b5
f0104956:	c1 e8 10             	shr    $0x10,%eax
f0104959:	66 a3 b6 13 23 f0    	mov    %ax,0xf02313b6
	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, t_irq_11, 0);
f010495f:	b8 5c 51 10 f0       	mov    $0xf010515c,%eax
f0104964:	66 a3 b8 13 23 f0    	mov    %ax,0xf02313b8
f010496a:	66 c7 05 ba 13 23 f0 	movw   $0x8,0xf02313ba
f0104971:	08 00 
f0104973:	c6 05 bc 13 23 f0 00 	movb   $0x0,0xf02313bc
f010497a:	c6 05 bd 13 23 f0 8e 	movb   $0x8e,0xf02313bd
f0104981:	c1 e8 10             	shr    $0x10,%eax
f0104984:	66 a3 be 13 23 f0    	mov    %ax,0xf02313be
	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, t_irq_12, 0);
f010498a:	b8 62 51 10 f0       	mov    $0xf0105162,%eax
f010498f:	66 a3 c0 13 23 f0    	mov    %ax,0xf02313c0
f0104995:	66 c7 05 c2 13 23 f0 	movw   $0x8,0xf02313c2
f010499c:	08 00 
f010499e:	c6 05 c4 13 23 f0 00 	movb   $0x0,0xf02313c4
f01049a5:	c6 05 c5 13 23 f0 8e 	movb   $0x8e,0xf02313c5
f01049ac:	c1 e8 10             	shr    $0x10,%eax
f01049af:	66 a3 c6 13 23 f0    	mov    %ax,0xf02313c6
	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, t_irq_13, 0);
f01049b5:	b8 68 51 10 f0       	mov    $0xf0105168,%eax
f01049ba:	66 a3 c8 13 23 f0    	mov    %ax,0xf02313c8
f01049c0:	66 c7 05 ca 13 23 f0 	movw   $0x8,0xf02313ca
f01049c7:	08 00 
f01049c9:	c6 05 cc 13 23 f0 00 	movb   $0x0,0xf02313cc
f01049d0:	c6 05 cd 13 23 f0 8e 	movb   $0x8e,0xf02313cd
f01049d7:	c1 e8 10             	shr    $0x10,%eax
f01049da:	66 a3 ce 13 23 f0    	mov    %ax,0xf02313ce
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, t_irq_ide, 0);
f01049e0:	b8 6e 51 10 f0       	mov    $0xf010516e,%eax
f01049e5:	66 a3 d0 13 23 f0    	mov    %ax,0xf02313d0
f01049eb:	66 c7 05 d2 13 23 f0 	movw   $0x8,0xf02313d2
f01049f2:	08 00 
f01049f4:	c6 05 d4 13 23 f0 00 	movb   $0x0,0xf02313d4
f01049fb:	c6 05 d5 13 23 f0 8e 	movb   $0x8e,0xf02313d5
f0104a02:	c1 e8 10             	shr    $0x10,%eax
f0104a05:	66 a3 d6 13 23 f0    	mov    %ax,0xf02313d6
	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, t_irq_15, 0);
f0104a0b:	b8 74 51 10 f0       	mov    $0xf0105174,%eax
f0104a10:	66 a3 d8 13 23 f0    	mov    %ax,0xf02313d8
f0104a16:	66 c7 05 da 13 23 f0 	movw   $0x8,0xf02313da
f0104a1d:	08 00 
f0104a1f:	c6 05 dc 13 23 f0 00 	movb   $0x0,0xf02313dc
f0104a26:	c6 05 dd 13 23 f0 8e 	movb   $0x8e,0xf02313dd
f0104a2d:	c1 e8 10             	shr    $0x10,%eax
f0104a30:	66 a3 de 13 23 f0    	mov    %ax,0xf02313de
	trap_init_percpu();
f0104a36:	e8 35 f9 ff ff       	call   f0104370 <trap_init_percpu>
}
f0104a3b:	c9                   	leave  
f0104a3c:	c3                   	ret    

f0104a3d <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104a3d:	55                   	push   %ebp
f0104a3e:	89 e5                	mov    %esp,%ebp
f0104a40:	53                   	push   %ebx
f0104a41:	83 ec 14             	sub    $0x14,%esp
f0104a44:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104a47:	8b 03                	mov    (%ebx),%eax
f0104a49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a4d:	c7 04 24 8d 89 10 f0 	movl   $0xf010898d,(%esp)
f0104a54:	e8 f7 f8 ff ff       	call   f0104350 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104a59:	8b 43 04             	mov    0x4(%ebx),%eax
f0104a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a60:	c7 04 24 9c 89 10 f0 	movl   $0xf010899c,(%esp)
f0104a67:	e8 e4 f8 ff ff       	call   f0104350 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104a6c:	8b 43 08             	mov    0x8(%ebx),%eax
f0104a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a73:	c7 04 24 ab 89 10 f0 	movl   $0xf01089ab,(%esp)
f0104a7a:	e8 d1 f8 ff ff       	call   f0104350 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104a7f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104a82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a86:	c7 04 24 ba 89 10 f0 	movl   $0xf01089ba,(%esp)
f0104a8d:	e8 be f8 ff ff       	call   f0104350 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104a92:	8b 43 10             	mov    0x10(%ebx),%eax
f0104a95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a99:	c7 04 24 c9 89 10 f0 	movl   $0xf01089c9,(%esp)
f0104aa0:	e8 ab f8 ff ff       	call   f0104350 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104aa5:	8b 43 14             	mov    0x14(%ebx),%eax
f0104aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104aac:	c7 04 24 d8 89 10 f0 	movl   $0xf01089d8,(%esp)
f0104ab3:	e8 98 f8 ff ff       	call   f0104350 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104ab8:	8b 43 18             	mov    0x18(%ebx),%eax
f0104abb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104abf:	c7 04 24 e7 89 10 f0 	movl   $0xf01089e7,(%esp)
f0104ac6:	e8 85 f8 ff ff       	call   f0104350 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104acb:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104ace:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ad2:	c7 04 24 f6 89 10 f0 	movl   $0xf01089f6,(%esp)
f0104ad9:	e8 72 f8 ff ff       	call   f0104350 <cprintf>
}
f0104ade:	83 c4 14             	add    $0x14,%esp
f0104ae1:	5b                   	pop    %ebx
f0104ae2:	5d                   	pop    %ebp
f0104ae3:	c3                   	ret    

f0104ae4 <print_trapframe>:
{
f0104ae4:	55                   	push   %ebp
f0104ae5:	89 e5                	mov    %esp,%ebp
f0104ae7:	56                   	push   %esi
f0104ae8:	53                   	push   %ebx
f0104ae9:	83 ec 10             	sub    $0x10,%esp
f0104aec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104aef:	e8 15 21 00 00       	call   f0106c09 <cpunum>
f0104af4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104af8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104afc:	c7 04 24 5a 8a 10 f0 	movl   $0xf0108a5a,(%esp)
f0104b03:	e8 48 f8 ff ff       	call   f0104350 <cprintf>
	print_regs(&tf->tf_regs);
f0104b08:	89 1c 24             	mov    %ebx,(%esp)
f0104b0b:	e8 2d ff ff ff       	call   f0104a3d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104b10:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104b14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b18:	c7 04 24 78 8a 10 f0 	movl   $0xf0108a78,(%esp)
f0104b1f:	e8 2c f8 ff ff       	call   f0104350 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104b24:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104b28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b2c:	c7 04 24 8b 8a 10 f0 	movl   $0xf0108a8b,(%esp)
f0104b33:	e8 18 f8 ff ff       	call   f0104350 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104b38:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0104b3b:	83 f8 13             	cmp    $0x13,%eax
f0104b3e:	77 09                	ja     f0104b49 <print_trapframe+0x65>
		return excnames[trapno];
f0104b40:	8b 14 85 40 8d 10 f0 	mov    -0xfef72c0(,%eax,4),%edx
f0104b47:	eb 1f                	jmp    f0104b68 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f0104b49:	83 f8 30             	cmp    $0x30,%eax
f0104b4c:	74 15                	je     f0104b63 <print_trapframe+0x7f>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104b4e:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104b51:	83 fa 0f             	cmp    $0xf,%edx
f0104b54:	ba 11 8a 10 f0       	mov    $0xf0108a11,%edx
f0104b59:	b9 24 8a 10 f0       	mov    $0xf0108a24,%ecx
f0104b5e:	0f 47 d1             	cmova  %ecx,%edx
f0104b61:	eb 05                	jmp    f0104b68 <print_trapframe+0x84>
		return "System call";
f0104b63:	ba 05 8a 10 f0       	mov    $0xf0108a05,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104b68:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b70:	c7 04 24 9e 8a 10 f0 	movl   $0xf0108a9e,(%esp)
f0104b77:	e8 d4 f7 ff ff       	call   f0104350 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104b7c:	3b 1d 60 1a 23 f0    	cmp    0xf0231a60,%ebx
f0104b82:	75 19                	jne    f0104b9d <print_trapframe+0xb9>
f0104b84:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104b88:	75 13                	jne    f0104b9d <print_trapframe+0xb9>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104b8a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b91:	c7 04 24 b0 8a 10 f0 	movl   $0xf0108ab0,(%esp)
f0104b98:	e8 b3 f7 ff ff       	call   f0104350 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104b9d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ba4:	c7 04 24 bf 8a 10 f0 	movl   $0xf0108abf,(%esp)
f0104bab:	e8 a0 f7 ff ff       	call   f0104350 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104bb0:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104bb4:	75 51                	jne    f0104c07 <print_trapframe+0x123>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104bb6:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104bb9:	89 c2                	mov    %eax,%edx
f0104bbb:	83 e2 01             	and    $0x1,%edx
f0104bbe:	ba 33 8a 10 f0       	mov    $0xf0108a33,%edx
f0104bc3:	b9 3e 8a 10 f0       	mov    $0xf0108a3e,%ecx
f0104bc8:	0f 45 ca             	cmovne %edx,%ecx
f0104bcb:	89 c2                	mov    %eax,%edx
f0104bcd:	83 e2 02             	and    $0x2,%edx
f0104bd0:	ba 4a 8a 10 f0       	mov    $0xf0108a4a,%edx
f0104bd5:	be 50 8a 10 f0       	mov    $0xf0108a50,%esi
f0104bda:	0f 44 d6             	cmove  %esi,%edx
f0104bdd:	83 e0 04             	and    $0x4,%eax
f0104be0:	b8 55 8a 10 f0       	mov    $0xf0108a55,%eax
f0104be5:	be 8a 8b 10 f0       	mov    $0xf0108b8a,%esi
f0104bea:	0f 44 c6             	cmove  %esi,%eax
f0104bed:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104bf1:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bf9:	c7 04 24 cd 8a 10 f0 	movl   $0xf0108acd,(%esp)
f0104c00:	e8 4b f7 ff ff       	call   f0104350 <cprintf>
f0104c05:	eb 0c                	jmp    f0104c13 <print_trapframe+0x12f>
		cprintf("\n");
f0104c07:	c7 04 24 30 76 10 f0 	movl   $0xf0107630,(%esp)
f0104c0e:	e8 3d f7 ff ff       	call   f0104350 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104c13:	8b 43 30             	mov    0x30(%ebx),%eax
f0104c16:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c1a:	c7 04 24 dc 8a 10 f0 	movl   $0xf0108adc,(%esp)
f0104c21:	e8 2a f7 ff ff       	call   f0104350 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104c26:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104c2a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c2e:	c7 04 24 eb 8a 10 f0 	movl   $0xf0108aeb,(%esp)
f0104c35:	e8 16 f7 ff ff       	call   f0104350 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104c3a:	8b 43 38             	mov    0x38(%ebx),%eax
f0104c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c41:	c7 04 24 fe 8a 10 f0 	movl   $0xf0108afe,(%esp)
f0104c48:	e8 03 f7 ff ff       	call   f0104350 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104c4d:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104c51:	74 27                	je     f0104c7a <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104c53:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104c56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c5a:	c7 04 24 0d 8b 10 f0 	movl   $0xf0108b0d,(%esp)
f0104c61:	e8 ea f6 ff ff       	call   f0104350 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104c66:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c6e:	c7 04 24 1c 8b 10 f0 	movl   $0xf0108b1c,(%esp)
f0104c75:	e8 d6 f6 ff ff       	call   f0104350 <cprintf>
}
f0104c7a:	83 c4 10             	add    $0x10,%esp
f0104c7d:	5b                   	pop    %ebx
f0104c7e:	5e                   	pop    %esi
f0104c7f:	5d                   	pop    %ebp
f0104c80:	c3                   	ret    

f0104c81 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104c81:	55                   	push   %ebp
f0104c82:	89 e5                	mov    %esp,%ebp
f0104c84:	57                   	push   %edi
f0104c85:	56                   	push   %esi
f0104c86:	53                   	push   %ebx
f0104c87:	83 ec 2c             	sub    $0x2c,%esp
f0104c8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104c8d:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	if ( (tf->tf_cs & 0x3) == 0 )
f0104c90:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104c94:	75 1c                	jne    f0104cb2 <page_fault_handler+0x31>
		panic("page_fault_handler: page fault in kernel mode");
f0104c96:	c7 44 24 08 d4 8c 10 	movl   $0xf0108cd4,0x8(%esp)
f0104c9d:	f0 
f0104c9e:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
f0104ca5:	00 
f0104ca6:	c7 04 24 2f 8b 10 f0 	movl   $0xf0108b2f,(%esp)
f0104cad:	e8 8e b3 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall)
f0104cb2:	e8 52 1f 00 00       	call   f0106c09 <cpunum>
f0104cb7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cba:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104cc0:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104cc4:	0f 84 0f 01 00 00    	je     f0104dd9 <page_fault_handler+0x158>
	{
		struct UTrapframe *utf;

		if ( (tf->tf_esp >= UXSTACKTOP-PGSIZE) && (tf->tf_esp < UXSTACKTOP) )
f0104cca:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104ccd:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0104cd3:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104cd9:	77 34                	ja     f0104d0f <page_fault_handler+0x8e>
		{
			utf = (struct UTrapframe *) (tf->tf_esp - 4 - sizeof(struct UTrapframe));
f0104cdb:	83 e8 38             	sub    $0x38,%eax
f0104cde:	89 c7                	mov    %eax,%edi
f0104ce0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			user_mem_assert(curenv, (void *)utf, tf->tf_esp - (uintptr_t)utf, PTE_W );
f0104ce3:	e8 21 1f 00 00       	call   f0106c09 <cpunum>
f0104ce8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104cef:	00 
f0104cf0:	c7 44 24 08 38 00 00 	movl   $0x38,0x8(%esp)
f0104cf7:	00 
f0104cf8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104cfc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cff:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104d05:	89 04 24             	mov    %eax,(%esp)
f0104d08:	e8 3d ec ff ff       	call   f010394a <user_mem_assert>
f0104d0d:	eb 35                	jmp    f0104d44 <page_fault_handler+0xc3>
		}
		else
		{
			utf = (struct UTrapframe *) (UXSTACKTOP - sizeof(struct UTrapframe));
			user_mem_assert(curenv, (void *)utf, UXSTACKTOP - (uintptr_t)utf, PTE_W );
f0104d0f:	e8 f5 1e 00 00       	call   f0106c09 <cpunum>
f0104d14:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104d1b:	00 
f0104d1c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104d23:	00 
f0104d24:	c7 44 24 04 cc ff bf 	movl   $0xeebfffcc,0x4(%esp)
f0104d2b:	ee 
f0104d2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d2f:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104d35:	89 04 24             	mov    %eax,(%esp)
f0104d38:	e8 0d ec ff ff       	call   f010394a <user_mem_assert>
			utf = (struct UTrapframe *) (UXSTACKTOP - sizeof(struct UTrapframe));
f0104d3d:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
		}

		utf->utf_fault_va = fault_va;
f0104d44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d47:	89 32                	mov    %esi,(%edx)
		utf->utf_err = tf->tf_err;
f0104d49:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104d4c:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs = tf->tf_regs;
f0104d4f:	8d 7a 08             	lea    0x8(%edx),%edi
f0104d52:	89 de                	mov    %ebx,%esi
f0104d54:	b8 20 00 00 00       	mov    $0x20,%eax
f0104d59:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104d5f:	74 03                	je     f0104d64 <page_fault_handler+0xe3>
f0104d61:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104d62:	b0 1f                	mov    $0x1f,%al
f0104d64:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104d6a:	74 05                	je     f0104d71 <page_fault_handler+0xf0>
f0104d6c:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104d6e:	83 e8 02             	sub    $0x2,%eax
f0104d71:	89 c1                	mov    %eax,%ecx
f0104d73:	c1 e9 02             	shr    $0x2,%ecx
f0104d76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104d78:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d7d:	a8 02                	test   $0x2,%al
f0104d7f:	74 0b                	je     f0104d8c <page_fault_handler+0x10b>
f0104d81:	0f b7 16             	movzwl (%esi),%edx
f0104d84:	66 89 17             	mov    %dx,(%edi)
f0104d87:	ba 02 00 00 00       	mov    $0x2,%edx
f0104d8c:	a8 01                	test   $0x1,%al
f0104d8e:	74 07                	je     f0104d97 <page_fault_handler+0x116>
f0104d90:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f0104d94:	88 04 17             	mov    %al,(%edi,%edx,1)
		utf->utf_eip = tf->tf_eip;
f0104d97:	8b 43 30             	mov    0x30(%ebx),%eax
f0104d9a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d9d:	89 46 28             	mov    %eax,0x28(%esi)
		utf->utf_eflags = tf->tf_eflags;
f0104da0:	8b 43 38             	mov    0x38(%ebx),%eax
f0104da3:	89 46 2c             	mov    %eax,0x2c(%esi)
		utf->utf_esp = tf->tf_esp;
f0104da6:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104da9:	89 46 30             	mov    %eax,0x30(%esi)

		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0104dac:	e8 58 1e 00 00       	call   f0106c09 <cpunum>
f0104db1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104db4:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104dba:	8b 40 64             	mov    0x64(%eax),%eax
f0104dbd:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uintptr_t) utf;
f0104dc0:	89 73 3c             	mov    %esi,0x3c(%ebx)
		env_run(curenv);
f0104dc3:	e8 41 1e 00 00       	call   f0106c09 <cpunum>
f0104dc8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dcb:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104dd1:	89 04 24             	mov    %eax,(%esp)
f0104dd4:	e8 69 f3 ff ff       	call   f0104142 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104dd9:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104ddc:	e8 28 1e 00 00       	call   f0106c09 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104de1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104de5:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104de9:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104dec:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104df2:	8b 40 48             	mov    0x48(%eax),%eax
f0104df5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104df9:	c7 04 24 04 8d 10 f0 	movl   $0xf0108d04,(%esp)
f0104e00:	e8 4b f5 ff ff       	call   f0104350 <cprintf>
	print_trapframe(tf);
f0104e05:	89 1c 24             	mov    %ebx,(%esp)
f0104e08:	e8 d7 fc ff ff       	call   f0104ae4 <print_trapframe>
	env_destroy(curenv);
f0104e0d:	e8 f7 1d 00 00       	call   f0106c09 <cpunum>
f0104e12:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e15:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104e1b:	89 04 24             	mov    %eax,(%esp)
f0104e1e:	e8 7e f2 ff ff       	call   f01040a1 <env_destroy>
}
f0104e23:	83 c4 2c             	add    $0x2c,%esp
f0104e26:	5b                   	pop    %ebx
f0104e27:	5e                   	pop    %esi
f0104e28:	5f                   	pop    %edi
f0104e29:	5d                   	pop    %ebp
f0104e2a:	c3                   	ret    

f0104e2b <trap>:
{
f0104e2b:	55                   	push   %ebp
f0104e2c:	89 e5                	mov    %esp,%ebp
f0104e2e:	57                   	push   %edi
f0104e2f:	56                   	push   %esi
f0104e30:	83 ec 20             	sub    $0x20,%esp
f0104e33:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104e36:	fc                   	cld    
	if (panicstr)
f0104e37:	83 3d 80 1e 23 f0 00 	cmpl   $0x0,0xf0231e80
f0104e3e:	74 01                	je     f0104e41 <trap+0x16>
		asm volatile("hlt");
f0104e40:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104e41:	e8 c3 1d 00 00       	call   f0106c09 <cpunum>
f0104e46:	6b d0 74             	imul   $0x74,%eax,%edx
f0104e49:	81 c2 20 20 23 f0    	add    $0xf0232020,%edx
	asm volatile("lock; xchgl %0, %1"
f0104e4f:	b8 01 00 00 00       	mov    $0x1,%eax
f0104e54:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104e58:	83 f8 02             	cmp    $0x2,%eax
f0104e5b:	75 0c                	jne    f0104e69 <trap+0x3e>
	spin_lock(&kernel_lock);
f0104e5d:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104e64:	e8 1e 20 00 00       	call   f0106e87 <spin_lock>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104e69:	9c                   	pushf  
f0104e6a:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104e6b:	f6 c4 02             	test   $0x2,%ah
f0104e6e:	74 24                	je     f0104e94 <trap+0x69>
f0104e70:	c7 44 24 0c 3b 8b 10 	movl   $0xf0108b3b,0xc(%esp)
f0104e77:	f0 
f0104e78:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0104e7f:	f0 
f0104e80:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f0104e87:	00 
f0104e88:	c7 04 24 2f 8b 10 f0 	movl   $0xf0108b2f,(%esp)
f0104e8f:	e8 ac b1 ff ff       	call   f0100040 <_panic>
	if ((tf->tf_cs & 3) == 3) {
f0104e94:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104e98:	83 e0 03             	and    $0x3,%eax
f0104e9b:	66 83 f8 03          	cmp    $0x3,%ax
f0104e9f:	0f 85 a7 00 00 00    	jne    f0104f4c <trap+0x121>
f0104ea5:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104eac:	e8 d6 1f 00 00       	call   f0106e87 <spin_lock>
		assert(curenv);
f0104eb1:	e8 53 1d 00 00       	call   f0106c09 <cpunum>
f0104eb6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eb9:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0104ec0:	75 24                	jne    f0104ee6 <trap+0xbb>
f0104ec2:	c7 44 24 0c 54 8b 10 	movl   $0xf0108b54,0xc(%esp)
f0104ec9:	f0 
f0104eca:	c7 44 24 08 15 7c 10 	movl   $0xf0107c15,0x8(%esp)
f0104ed1:	f0 
f0104ed2:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
f0104ed9:	00 
f0104eda:	c7 04 24 2f 8b 10 f0 	movl   $0xf0108b2f,(%esp)
f0104ee1:	e8 5a b1 ff ff       	call   f0100040 <_panic>
		if (curenv->env_status == ENV_DYING) {
f0104ee6:	e8 1e 1d 00 00       	call   f0106c09 <cpunum>
f0104eeb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eee:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104ef4:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104ef8:	75 2d                	jne    f0104f27 <trap+0xfc>
			env_free(curenv);
f0104efa:	e8 0a 1d 00 00       	call   f0106c09 <cpunum>
f0104eff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f02:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104f08:	89 04 24             	mov    %eax,(%esp)
f0104f0b:	e8 8c ef ff ff       	call   f0103e9c <env_free>
			curenv = NULL;
f0104f10:	e8 f4 1c 00 00       	call   f0106c09 <cpunum>
f0104f15:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f18:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f0104f1f:	00 00 00 
			sched_yield();
f0104f22:	e8 3b 03 00 00       	call   f0105262 <sched_yield>
		curenv->env_tf = *tf;
f0104f27:	e8 dd 1c 00 00       	call   f0106c09 <cpunum>
f0104f2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f2f:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0104f35:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104f3a:	89 c7                	mov    %eax,%edi
f0104f3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104f3e:	e8 c6 1c 00 00       	call   f0106c09 <cpunum>
f0104f43:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f46:	8b b0 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%esi
	last_tf = tf;
f0104f4c:	89 35 60 1a 23 f0    	mov    %esi,0xf0231a60
	if (curenv == NULL) envid = 0;
f0104f52:	e8 b2 1c 00 00       	call   f0106c09 <cpunum>
f0104f57:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f5a:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0104f61:	74 05                	je     f0104f68 <trap+0x13d>
	else envid = curenv->env_id;
f0104f63:	e8 a1 1c 00 00       	call   f0106c09 <cpunum>
	switch(tf->tf_trapno)
f0104f68:	8b 46 28             	mov    0x28(%esi),%eax
f0104f6b:	83 f8 0e             	cmp    $0xe,%eax
f0104f6e:	74 19                	je     f0104f89 <trap+0x15e>
f0104f70:	83 f8 0e             	cmp    $0xe,%eax
f0104f73:	77 07                	ja     f0104f7c <trap+0x151>
f0104f75:	83 f8 03             	cmp    $0x3,%eax
f0104f78:	74 20                	je     f0104f9a <trap+0x16f>
f0104f7a:	eb 69                	jmp    f0104fe5 <trap+0x1ba>
f0104f7c:	83 f8 20             	cmp    $0x20,%eax
f0104f7f:	90                   	nop
f0104f80:	74 57                	je     f0104fd9 <trap+0x1ae>
f0104f82:	83 f8 30             	cmp    $0x30,%eax
f0104f85:	74 20                	je     f0104fa7 <trap+0x17c>
f0104f87:	eb 5c                	jmp    f0104fe5 <trap+0x1ba>
			return page_fault_handler(tf);
f0104f89:	89 34 24             	mov    %esi,(%esp)
f0104f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104f90:	e8 ec fc ff ff       	call   f0104c81 <page_fault_handler>
f0104f95:	e9 a7 00 00 00       	jmp    f0105041 <trap+0x216>
			return monitor(tf);
f0104f9a:	89 34 24             	mov    %esi,(%esp)
f0104f9d:	e8 fc ba ff ff       	call   f0100a9e <monitor>
f0104fa2:	e9 9a 00 00 00       	jmp    f0105041 <trap+0x216>
			int32_t ret = syscall(tf->tf_regs.reg_eax, 
f0104fa7:	8b 46 04             	mov    0x4(%esi),%eax
f0104faa:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104fae:	8b 06                	mov    (%esi),%eax
f0104fb0:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104fb4:	8b 46 10             	mov    0x10(%esi),%eax
f0104fb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104fbb:	8b 46 18             	mov    0x18(%esi),%eax
f0104fbe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fc2:	8b 46 14             	mov    0x14(%esi),%eax
f0104fc5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fc9:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104fcc:	89 04 24             	mov    %eax,(%esp)
f0104fcf:	e8 4c 03 00 00       	call   f0105320 <syscall>
			tf->tf_regs.reg_eax = ret;
f0104fd4:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104fd7:	eb 68                	jmp    f0105041 <trap+0x216>
			lapic_eoi();
f0104fd9:	e8 78 1d 00 00       	call   f0106d56 <lapic_eoi>
			sched_yield();
f0104fde:	66 90                	xchg   %ax,%ax
f0104fe0:	e8 7d 02 00 00       	call   f0105262 <sched_yield>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104fe5:	83 f8 27             	cmp    $0x27,%eax
f0104fe8:	75 16                	jne    f0105000 <trap+0x1d5>
		cprintf("Spurious interrupt on irq 7\n");
f0104fea:	c7 04 24 5b 8b 10 f0 	movl   $0xf0108b5b,(%esp)
f0104ff1:	e8 5a f3 ff ff       	call   f0104350 <cprintf>
		print_trapframe(tf);
f0104ff6:	89 34 24             	mov    %esi,(%esp)
f0104ff9:	e8 e6 fa ff ff       	call   f0104ae4 <print_trapframe>
f0104ffe:	eb 41                	jmp    f0105041 <trap+0x216>
	print_trapframe(tf);
f0105000:	89 34 24             	mov    %esi,(%esp)
f0105003:	e8 dc fa ff ff       	call   f0104ae4 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0105008:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010500d:	75 1c                	jne    f010502b <trap+0x200>
		panic("unhandled trap in kernel");
f010500f:	c7 44 24 08 78 8b 10 	movl   $0xf0108b78,0x8(%esp)
f0105016:	f0 
f0105017:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
f010501e:	00 
f010501f:	c7 04 24 2f 8b 10 f0 	movl   $0xf0108b2f,(%esp)
f0105026:	e8 15 b0 ff ff       	call   f0100040 <_panic>
		env_destroy(curenv);
f010502b:	e8 d9 1b 00 00       	call   f0106c09 <cpunum>
f0105030:	6b c0 74             	imul   $0x74,%eax,%eax
f0105033:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105039:	89 04 24             	mov    %eax,(%esp)
f010503c:	e8 60 f0 ff ff       	call   f01040a1 <env_destroy>
	if (curenv && curenv->env_status == ENV_RUNNING)
f0105041:	e8 c3 1b 00 00       	call   f0106c09 <cpunum>
f0105046:	6b c0 74             	imul   $0x74,%eax,%eax
f0105049:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f0105050:	74 2a                	je     f010507c <trap+0x251>
f0105052:	e8 b2 1b 00 00       	call   f0106c09 <cpunum>
f0105057:	6b c0 74             	imul   $0x74,%eax,%eax
f010505a:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105060:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0105064:	75 16                	jne    f010507c <trap+0x251>
		env_run(curenv);
f0105066:	e8 9e 1b 00 00       	call   f0106c09 <cpunum>
f010506b:	6b c0 74             	imul   $0x74,%eax,%eax
f010506e:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105074:	89 04 24             	mov    %eax,(%esp)
f0105077:	e8 c6 f0 ff ff       	call   f0104142 <env_run>
		sched_yield();
f010507c:	e8 e1 01 00 00       	call   f0105262 <sched_yield>
f0105081:	90                   	nop

f0105082 <t_divide>:
// HINT 2 : TRAPHANDLER(t_dblflt, T_DBLFLT);
//          Do something like this if the trap includes an error code..
// HINT 3 : READ Intel's manual to check if the trap includes an error code
//          or not...

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);
f0105082:	6a 00                	push   $0x0
f0105084:	6a 00                	push   $0x0
f0105086:	e9 ef 00 00 00       	jmp    f010517a <_alltraps>
f010508b:	90                   	nop

f010508c <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);
f010508c:	6a 00                	push   $0x0
f010508e:	6a 01                	push   $0x1
f0105090:	e9 e5 00 00 00       	jmp    f010517a <_alltraps>
f0105095:	90                   	nop

f0105096 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);
f0105096:	6a 00                	push   $0x0
f0105098:	6a 02                	push   $0x2
f010509a:	e9 db 00 00 00       	jmp    f010517a <_alltraps>
f010509f:	90                   	nop

f01050a0 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT);
f01050a0:	6a 00                	push   $0x0
f01050a2:	6a 03                	push   $0x3
f01050a4:	e9 d1 00 00 00       	jmp    f010517a <_alltraps>
f01050a9:	90                   	nop

f01050aa <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW);
f01050aa:	6a 00                	push   $0x0
f01050ac:	6a 04                	push   $0x4
f01050ae:	e9 c7 00 00 00       	jmp    f010517a <_alltraps>
f01050b3:	90                   	nop

f01050b4 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND);
f01050b4:	6a 00                	push   $0x0
f01050b6:	6a 05                	push   $0x5
f01050b8:	e9 bd 00 00 00       	jmp    f010517a <_alltraps>
f01050bd:	90                   	nop

f01050be <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP);
f01050be:	6a 00                	push   $0x0
f01050c0:	6a 06                	push   $0x6
f01050c2:	e9 b3 00 00 00       	jmp    f010517a <_alltraps>
f01050c7:	90                   	nop

f01050c8 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE);
f01050c8:	6a 00                	push   $0x0
f01050ca:	6a 07                	push   $0x7
f01050cc:	e9 a9 00 00 00       	jmp    f010517a <_alltraps>
f01050d1:	90                   	nop

f01050d2 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT);
f01050d2:	6a 08                	push   $0x8
f01050d4:	e9 a1 00 00 00       	jmp    f010517a <_alltraps>
f01050d9:	90                   	nop

f01050da <t_tss>:
TRAPHANDLER(t_tss, T_TSS);
f01050da:	6a 0a                	push   $0xa
f01050dc:	e9 99 00 00 00       	jmp    f010517a <_alltraps>
f01050e1:	90                   	nop

f01050e2 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP);
f01050e2:	6a 0b                	push   $0xb
f01050e4:	e9 91 00 00 00       	jmp    f010517a <_alltraps>
f01050e9:	90                   	nop

f01050ea <t_stack>:
TRAPHANDLER(t_stack, T_STACK);
f01050ea:	6a 0c                	push   $0xc
f01050ec:	e9 89 00 00 00       	jmp    f010517a <_alltraps>
f01050f1:	90                   	nop

f01050f2 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT);
f01050f2:	6a 0d                	push   $0xd
f01050f4:	e9 81 00 00 00       	jmp    f010517a <_alltraps>
f01050f9:	90                   	nop

f01050fa <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT);
f01050fa:	6a 0e                	push   $0xe
f01050fc:	eb 7c                	jmp    f010517a <_alltraps>

f01050fe <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR);
f01050fe:	6a 00                	push   $0x0
f0105100:	6a 10                	push   $0x10
f0105102:	eb 76                	jmp    f010517a <_alltraps>

f0105104 <t_align>:
TRAPHANDLER(t_align, T_ALIGN);
f0105104:	6a 11                	push   $0x11
f0105106:	eb 72                	jmp    f010517a <_alltraps>

f0105108 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK);
f0105108:	6a 00                	push   $0x0
f010510a:	6a 12                	push   $0x12
f010510c:	eb 6c                	jmp    f010517a <_alltraps>

f010510e <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR);
f010510e:	6a 00                	push   $0x0
f0105110:	6a 13                	push   $0x13
f0105112:	eb 66                	jmp    f010517a <_alltraps>

f0105114 <t_syscall>:
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL);
f0105114:	6a 00                	push   $0x0
f0105116:	6a 30                	push   $0x30
f0105118:	eb 60                	jmp    f010517a <_alltraps>

f010511a <t_irq_timer>:

TRAPHANDLER_NOEC(t_irq_timer, IRQ_OFFSET + IRQ_TIMER);	//	32 + 0
f010511a:	6a 00                	push   $0x0
f010511c:	6a 20                	push   $0x20
f010511e:	eb 5a                	jmp    f010517a <_alltraps>

f0105120 <t_irq_kbd>:
TRAPHANDLER_NOEC(t_irq_kbd, IRQ_OFFSET + IRQ_KBD);
f0105120:	6a 00                	push   $0x0
f0105122:	6a 21                	push   $0x21
f0105124:	eb 54                	jmp    f010517a <_alltraps>

f0105126 <t_irq_2>:
TRAPHANDLER_NOEC(t_irq_2, IRQ_OFFSET + 2);
f0105126:	6a 00                	push   $0x0
f0105128:	6a 22                	push   $0x22
f010512a:	eb 4e                	jmp    f010517a <_alltraps>

f010512c <t_irq_3>:
TRAPHANDLER_NOEC(t_irq_3, IRQ_OFFSET + 3);
f010512c:	6a 00                	push   $0x0
f010512e:	6a 23                	push   $0x23
f0105130:	eb 48                	jmp    f010517a <_alltraps>

f0105132 <t_irq_serial>:
TRAPHANDLER_NOEC(t_irq_serial, IRQ_OFFSET + IRQ_SERIAL);
f0105132:	6a 00                	push   $0x0
f0105134:	6a 24                	push   $0x24
f0105136:	eb 42                	jmp    f010517a <_alltraps>

f0105138 <t_irq_5>:
TRAPHANDLER_NOEC(t_irq_5, IRQ_OFFSET + 5);
f0105138:	6a 00                	push   $0x0
f010513a:	6a 25                	push   $0x25
f010513c:	eb 3c                	jmp    f010517a <_alltraps>

f010513e <t_irq_6>:
TRAPHANDLER_NOEC(t_irq_6, IRQ_OFFSET + 6);
f010513e:	6a 00                	push   $0x0
f0105140:	6a 26                	push   $0x26
f0105142:	eb 36                	jmp    f010517a <_alltraps>

f0105144 <t_irq_spurious>:
TRAPHANDLER_NOEC(t_irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS);
f0105144:	6a 00                	push   $0x0
f0105146:	6a 27                	push   $0x27
f0105148:	eb 30                	jmp    f010517a <_alltraps>

f010514a <t_irq_8>:
TRAPHANDLER_NOEC(t_irq_8, IRQ_OFFSET + 8);
f010514a:	6a 00                	push   $0x0
f010514c:	6a 28                	push   $0x28
f010514e:	eb 2a                	jmp    f010517a <_alltraps>

f0105150 <t_irq_9>:
TRAPHANDLER_NOEC(t_irq_9, IRQ_OFFSET + 9);
f0105150:	6a 00                	push   $0x0
f0105152:	6a 29                	push   $0x29
f0105154:	eb 24                	jmp    f010517a <_alltraps>

f0105156 <t_irq_10>:
TRAPHANDLER_NOEC(t_irq_10, IRQ_OFFSET + 10);
f0105156:	6a 00                	push   $0x0
f0105158:	6a 2a                	push   $0x2a
f010515a:	eb 1e                	jmp    f010517a <_alltraps>

f010515c <t_irq_11>:
TRAPHANDLER_NOEC(t_irq_11, IRQ_OFFSET + 11);
f010515c:	6a 00                	push   $0x0
f010515e:	6a 2b                	push   $0x2b
f0105160:	eb 18                	jmp    f010517a <_alltraps>

f0105162 <t_irq_12>:
TRAPHANDLER_NOEC(t_irq_12, IRQ_OFFSET + 12);
f0105162:	6a 00                	push   $0x0
f0105164:	6a 2c                	push   $0x2c
f0105166:	eb 12                	jmp    f010517a <_alltraps>

f0105168 <t_irq_13>:
TRAPHANDLER_NOEC(t_irq_13, IRQ_OFFSET + 13);
f0105168:	6a 00                	push   $0x0
f010516a:	6a 2d                	push   $0x2d
f010516c:	eb 0c                	jmp    f010517a <_alltraps>

f010516e <t_irq_ide>:
TRAPHANDLER_NOEC(t_irq_ide, IRQ_OFFSET + IRQ_IDE);
f010516e:	6a 00                	push   $0x0
f0105170:	6a 2e                	push   $0x2e
f0105172:	eb 06                	jmp    f010517a <_alltraps>

f0105174 <t_irq_15>:
TRAPHANDLER_NOEC(t_irq_15, IRQ_OFFSET + 15);
f0105174:	6a 00                	push   $0x0
f0105176:	6a 2f                	push   $0x2f
f0105178:	eb 00                	jmp    f010517a <_alltraps>

f010517a <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
  pushl %ds
f010517a:	1e                   	push   %ds
  pushl %es
f010517b:	06                   	push   %es
  pushal
f010517c:	60                   	pusha  

  movl $GD_KD, %eax
f010517d:	b8 10 00 00 00       	mov    $0x10,%eax
  movw %ax, %ds
f0105182:	8e d8                	mov    %eax,%ds
  movw %ax, %es
f0105184:	8e c0                	mov    %eax,%es

  pushl %esp
f0105186:	54                   	push   %esp

  call trap
f0105187:	e8 9f fc ff ff       	call   f0104e2b <trap>

f010518c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010518c:	55                   	push   %ebp
f010518d:	89 e5                	mov    %esp,%ebp
f010518f:	83 ec 18             	sub    $0x18,%esp
f0105192:	8b 15 48 12 23 f0    	mov    0xf0231248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0105198:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010519d:	8b 4a 54             	mov    0x54(%edx),%ecx
f01051a0:	83 e9 01             	sub    $0x1,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01051a3:	83 f9 02             	cmp    $0x2,%ecx
f01051a6:	76 0f                	jbe    f01051b7 <sched_halt+0x2b>
	for (i = 0; i < NENV; i++) {
f01051a8:	83 c0 01             	add    $0x1,%eax
f01051ab:	83 c2 7c             	add    $0x7c,%edx
f01051ae:	3d 00 04 00 00       	cmp    $0x400,%eax
f01051b3:	75 e8                	jne    f010519d <sched_halt+0x11>
f01051b5:	eb 07                	jmp    f01051be <sched_halt+0x32>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01051b7:	3d 00 04 00 00       	cmp    $0x400,%eax
f01051bc:	75 1a                	jne    f01051d8 <sched_halt+0x4c>
		cprintf("No runnable environments in the system!\n");
f01051be:	c7 04 24 90 8d 10 f0 	movl   $0xf0108d90,(%esp)
f01051c5:	e8 86 f1 ff ff       	call   f0104350 <cprintf>
		while (1)
			monitor(NULL);
f01051ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01051d1:	e8 c8 b8 ff ff       	call   f0100a9e <monitor>
f01051d6:	eb f2                	jmp    f01051ca <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01051d8:	e8 2c 1a 00 00       	call   f0106c09 <cpunum>
f01051dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01051e0:	c7 80 28 20 23 f0 00 	movl   $0x0,-0xfdcdfd8(%eax)
f01051e7:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01051ea:	a1 8c 1e 23 f0       	mov    0xf0231e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01051ef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01051f4:	77 20                	ja     f0105216 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01051f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01051fa:	c7 44 24 08 28 73 10 	movl   $0xf0107328,0x8(%esp)
f0105201:	f0 
f0105202:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
f0105209:	00 
f010520a:	c7 04 24 b9 8d 10 f0 	movl   $0xf0108db9,(%esp)
f0105211:	e8 2a ae ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0105216:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010521b:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010521e:	e8 e6 19 00 00       	call   f0106c09 <cpunum>
f0105223:	6b d0 74             	imul   $0x74,%eax,%edx
f0105226:	81 c2 20 20 23 f0    	add    $0xf0232020,%edx
	asm volatile("lock; xchgl %0, %1"
f010522c:	b8 02 00 00 00       	mov    $0x2,%eax
f0105231:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
	spin_unlock(&kernel_lock);
f0105235:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010523c:	e8 f2 1c 00 00       	call   f0106f33 <spin_unlock>
	asm volatile("pause");
f0105241:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0105243:	e8 c1 19 00 00       	call   f0106c09 <cpunum>
f0105248:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f010524b:	8b 80 30 20 23 f0    	mov    -0xfdcdfd0(%eax),%eax
f0105251:	bd 00 00 00 00       	mov    $0x0,%ebp
f0105256:	89 c4                	mov    %eax,%esp
f0105258:	6a 00                	push   $0x0
f010525a:	6a 00                	push   $0x0
f010525c:	fb                   	sti    
f010525d:	f4                   	hlt    
f010525e:	eb fd                	jmp    f010525d <sched_halt+0xd1>
}
f0105260:	c9                   	leave  
f0105261:	c3                   	ret    

f0105262 <sched_yield>:
{
f0105262:	55                   	push   %ebp
f0105263:	89 e5                	mov    %esp,%ebp
f0105265:	56                   	push   %esi
f0105266:	53                   	push   %ebx
f0105267:	83 ec 10             	sub    $0x10,%esp
	if(curenv)
f010526a:	e8 9a 19 00 00       	call   f0106c09 <cpunum>
f010526f:	6b d0 74             	imul   $0x74,%eax,%edx
		env_idx = 0;
f0105272:	b8 00 00 00 00       	mov    $0x0,%eax
	if(curenv)
f0105277:	83 ba 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%edx)
f010527e:	74 16                	je     f0105296 <sched_yield+0x34>
		env_idx = ENVX(curenv->env_id);
f0105280:	e8 84 19 00 00       	call   f0106c09 <cpunum>
f0105285:	6b c0 74             	imul   $0x74,%eax,%eax
f0105288:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010528e:	8b 40 48             	mov    0x48(%eax),%eax
f0105291:	25 ff 03 00 00       	and    $0x3ff,%eax
		if( envs[ i % NENV ].env_status == ENV_RUNNABLE )
f0105296:	8b 1d 48 12 23 f0    	mov    0xf0231248,%ebx
f010529c:	8d 88 00 04 00 00    	lea    0x400(%eax),%ecx
	for( i = env_idx; i != env_idx + NENV; i++ )
f01052a2:	eb 25                	jmp    f01052c9 <sched_yield+0x67>
		if( envs[ i % NENV ].env_status == ENV_RUNNABLE )
f01052a4:	99                   	cltd   
f01052a5:	c1 ea 16             	shr    $0x16,%edx
f01052a8:	8d 34 10             	lea    (%eax,%edx,1),%esi
f01052ab:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f01052b1:	29 d6                	sub    %edx,%esi
f01052b3:	6b d6 7c             	imul   $0x7c,%esi,%edx
f01052b6:	01 da                	add    %ebx,%edx
f01052b8:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f01052bc:	75 08                	jne    f01052c6 <sched_yield+0x64>
			env_run(&envs[ i % NENV ]);
f01052be:	89 14 24             	mov    %edx,(%esp)
f01052c1:	e8 7c ee ff ff       	call   f0104142 <env_run>
	for( i = env_idx; i != env_idx + NENV; i++ )
f01052c6:	83 c0 01             	add    $0x1,%eax
f01052c9:	39 c8                	cmp    %ecx,%eax
f01052cb:	75 d7                	jne    f01052a4 <sched_yield+0x42>
	if( curenv && (curenv->env_status == ENV_RUNNING) )
f01052cd:	e8 37 19 00 00       	call   f0106c09 <cpunum>
f01052d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01052d5:	83 b8 28 20 23 f0 00 	cmpl   $0x0,-0xfdcdfd8(%eax)
f01052dc:	74 2a                	je     f0105308 <sched_yield+0xa6>
f01052de:	e8 26 19 00 00       	call   f0106c09 <cpunum>
f01052e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01052e6:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01052ec:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01052f0:	75 16                	jne    f0105308 <sched_yield+0xa6>
		env_run(curenv);
f01052f2:	e8 12 19 00 00       	call   f0106c09 <cpunum>
f01052f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01052fa:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105300:	89 04 24             	mov    %eax,(%esp)
f0105303:	e8 3a ee ff ff       	call   f0104142 <env_run>
	sched_halt();
f0105308:	e8 7f fe ff ff       	call   f010518c <sched_halt>
}
f010530d:	83 c4 10             	add    $0x10,%esp
f0105310:	5b                   	pop    %ebx
f0105311:	5e                   	pop    %esi
f0105312:	5d                   	pop    %ebp
f0105313:	c3                   	ret    
f0105314:	66 90                	xchg   %ax,%ax
f0105316:	66 90                	xchg   %ax,%ax
f0105318:	66 90                	xchg   %ax,%ax
f010531a:	66 90                	xchg   %ax,%ax
f010531c:	66 90                	xchg   %ax,%ax
f010531e:	66 90                	xchg   %ax,%ax

f0105320 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105320:	55                   	push   %ebp
f0105321:	89 e5                	mov    %esp,%ebp
f0105323:	57                   	push   %edi
f0105324:	56                   	push   %esi
f0105325:	53                   	push   %ebx
f0105326:	83 ec 2c             	sub    $0x2c,%esp
f0105329:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
f010532c:	83 f8 0c             	cmp    $0xc,%eax
f010532f:	0f 87 cf 05 00 00    	ja     f0105904 <syscall+0x5e4>
f0105335:	ff 24 85 00 8e 10 f0 	jmp    *-0xfef7200(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U | PTE_P);
f010533c:	e8 c8 18 00 00       	call   f0106c09 <cpunum>
f0105341:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0105348:	00 
f0105349:	8b 7d 10             	mov    0x10(%ebp),%edi
f010534c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105350:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105353:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105357:	6b c0 74             	imul   $0x74,%eax,%eax
f010535a:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105360:	89 04 24             	mov    %eax,(%esp)
f0105363:	e8 e2 e5 ff ff       	call   f010394a <user_mem_assert>
	cprintf("%.*s", len, s);
f0105368:	8b 45 0c             	mov    0xc(%ebp),%eax
f010536b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010536f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105372:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105376:	c7 04 24 c6 8d 10 f0 	movl   $0xf0108dc6,(%esp)
f010537d:	e8 ce ef ff ff       	call   f0104350 <cprintf>
		case SYS_cputs:
		{
			sys_cputs((const char *)a1, (size_t)a2);
			return 0;
f0105382:	b8 00 00 00 00       	mov    $0x0,%eax
f0105387:	e9 e2 05 00 00       	jmp    f010596e <syscall+0x64e>
	return cons_getc();
f010538c:	e8 94 b2 ff ff       	call   f0100625 <cons_getc>
		}
		case SYS_cgetc: return sys_cgetc();
f0105391:	e9 d8 05 00 00       	jmp    f010596e <syscall+0x64e>
	return curenv->env_id;
f0105396:	e8 6e 18 00 00       	call   f0106c09 <cpunum>
f010539b:	6b c0 74             	imul   $0x74,%eax,%eax
f010539e:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01053a4:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_getenvid: return sys_getenvid();
f01053a7:	e9 c2 05 00 00       	jmp    f010596e <syscall+0x64e>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01053ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01053b3:	00 
f01053b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01053b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01053be:	89 04 24             	mov    %eax,(%esp)
f01053c1:	e8 a1 e6 ff ff       	call   f0103a67 <envid2env>
		return r;
f01053c6:	89 c2                	mov    %eax,%edx
	if ((r = envid2env(envid, &e, 1)) < 0)
f01053c8:	85 c0                	test   %eax,%eax
f01053ca:	78 6e                	js     f010543a <syscall+0x11a>
	if (e == curenv)
f01053cc:	e8 38 18 00 00       	call   f0106c09 <cpunum>
f01053d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01053d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01053d7:	39 90 28 20 23 f0    	cmp    %edx,-0xfdcdfd8(%eax)
f01053dd:	75 23                	jne    f0105402 <syscall+0xe2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01053df:	e8 25 18 00 00       	call   f0106c09 <cpunum>
f01053e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01053e7:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01053ed:	8b 40 48             	mov    0x48(%eax),%eax
f01053f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053f4:	c7 04 24 cb 8d 10 f0 	movl   $0xf0108dcb,(%esp)
f01053fb:	e8 50 ef ff ff       	call   f0104350 <cprintf>
f0105400:	eb 28                	jmp    f010542a <syscall+0x10a>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105402:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105405:	e8 ff 17 00 00       	call   f0106c09 <cpunum>
f010540a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010540e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105411:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105417:	8b 40 48             	mov    0x48(%eax),%eax
f010541a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010541e:	c7 04 24 e6 8d 10 f0 	movl   $0xf0108de6,(%esp)
f0105425:	e8 26 ef ff ff       	call   f0104350 <cprintf>
	env_destroy(e);
f010542a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010542d:	89 04 24             	mov    %eax,(%esp)
f0105430:	e8 6c ec ff ff       	call   f01040a1 <env_destroy>
	return 0;
f0105435:	ba 00 00 00 00       	mov    $0x0,%edx
		case SYS_env_destroy: return sys_env_destroy(a1);
f010543a:	89 d0                	mov    %edx,%eax
f010543c:	e9 2d 05 00 00       	jmp    f010596e <syscall+0x64e>
	sched_yield();
f0105441:	e8 1c fe ff ff       	call   f0105262 <sched_yield>
	if ((r=env_alloc(&e, curenv->env_id)) != 0)
f0105446:	e8 be 17 00 00       	call   f0106c09 <cpunum>
f010544b:	6b c0 74             	imul   $0x74,%eax,%eax
f010544e:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105454:	8b 40 48             	mov    0x48(%eax),%eax
f0105457:	89 44 24 04          	mov    %eax,0x4(%esp)
f010545b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010545e:	89 04 24             	mov    %eax,(%esp)
f0105461:	e8 12 e7 ff ff       	call   f0103b78 <env_alloc>
		return r;
f0105466:	89 c2                	mov    %eax,%edx
	if ((r=env_alloc(&e, curenv->env_id)) != 0)
f0105468:	85 c0                	test   %eax,%eax
f010546a:	75 2e                	jne    f010549a <syscall+0x17a>
	e->env_status = ENV_NOT_RUNNABLE;
f010546c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010546f:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0105476:	e8 8e 17 00 00       	call   f0106c09 <cpunum>
f010547b:	6b c0 74             	imul   $0x74,%eax,%eax
f010547e:	8b b0 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%esi
f0105484:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105489:	89 df                	mov    %ebx,%edi
f010548b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f010548d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105490:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0105497:	8b 50 48             	mov    0x48(%eax),%edx
		case SYS_yield:
		{
			sys_yield();
			return 0;
		}
		case SYS_exofork: return sys_exofork();
f010549a:	89 d0                	mov    %edx,%eax
f010549c:	e9 cd 04 00 00       	jmp    f010596e <syscall+0x64e>
	struct Env *e = NULL;
f01054a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01054a8:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f01054ac:	74 06                	je     f01054b4 <syscall+0x194>
f01054ae:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f01054b2:	75 2d                	jne    f01054e1 <syscall+0x1c1>
	if ((r=envid2env(envid, &e, 1)) != 0)
f01054b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054bb:	00 
f01054bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01054bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054c6:	89 04 24             	mov    %eax,(%esp)
f01054c9:	e8 99 e5 ff ff       	call   f0103a67 <envid2env>
		return r;
f01054ce:	89 c2                	mov    %eax,%edx
	if ((r=envid2env(envid, &e, 1)) != 0)
f01054d0:	85 c0                	test   %eax,%eax
f01054d2:	75 12                	jne    f01054e6 <syscall+0x1c6>
	e->env_status = status;
f01054d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01054d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01054da:	89 4a 54             	mov    %ecx,0x54(%edx)
	return 0;
f01054dd:	89 c2                	mov    %eax,%edx
f01054df:	eb 05                	jmp    f01054e6 <syscall+0x1c6>
		return -E_INVAL;
f01054e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
		case SYS_env_set_status: return sys_env_set_status(a1, a2);
f01054e6:	89 d0                	mov    %edx,%eax
f01054e8:	e9 81 04 00 00       	jmp    f010596e <syscall+0x64e>
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01054ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01054f4:	e8 b1 bf ff ff       	call   f01014aa <page_alloc>
f01054f9:	89 c3                	mov    %eax,%ebx
	if (!pp)
f01054fb:	85 c0                	test   %eax,%eax
f01054fd:	74 6e                	je     f010556d <syscall+0x24d>
	if ((uint32_t)va >= UTOP || ((uintptr_t)va % PGSIZE != 0))
f01054ff:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105506:	77 6f                	ja     f0105577 <syscall+0x257>
f0105508:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010550f:	75 70                	jne    f0105581 <syscall+0x261>
	if( (perm & PTE_U) != PTE_U)
f0105511:	f6 45 14 04          	testb  $0x4,0x14(%ebp)
f0105515:	74 74                	je     f010558b <syscall+0x26b>
	if((perm & ~PTE_SYSCALL) != 0)
f0105517:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f010551e:	75 75                	jne    f0105595 <syscall+0x275>
	if ((r=envid2env(envid, &e, 1)) < 0)
f0105520:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105527:	00 
f0105528:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010552b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010552f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105532:	89 04 24             	mov    %eax,(%esp)
f0105535:	e8 2d e5 ff ff       	call   f0103a67 <envid2env>
f010553a:	85 c0                	test   %eax,%eax
f010553c:	0f 88 2c 04 00 00    	js     f010596e <syscall+0x64e>
	if ((r=page_insert(e->env_pgdir, pp, va, perm)) < 0)
f0105542:	8b 45 14             	mov    0x14(%ebp),%eax
f0105545:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105549:	8b 45 10             	mov    0x10(%ebp),%eax
f010554c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105550:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105554:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105557:	8b 40 60             	mov    0x60(%eax),%eax
f010555a:	89 04 24             	mov    %eax,(%esp)
f010555d:	e8 99 c2 ff ff       	call   f01017fb <page_insert>
		return -E_NO_MEM;
f0105562:	c1 f8 1f             	sar    $0x1f,%eax
f0105565:	83 e0 fc             	and    $0xfffffffc,%eax
f0105568:	e9 01 04 00 00       	jmp    f010596e <syscall+0x64e>
		return -E_NO_MEM;
f010556d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105572:	e9 f7 03 00 00       	jmp    f010596e <syscall+0x64e>
		return -E_INVAL;
f0105577:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010557c:	e9 ed 03 00 00       	jmp    f010596e <syscall+0x64e>
f0105581:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105586:	e9 e3 03 00 00       	jmp    f010596e <syscall+0x64e>
		return -E_INVAL;
f010558b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105590:	e9 d9 03 00 00       	jmp    f010596e <syscall+0x64e>
		return -E_INVAL;	
f0105595:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010559a:	e9 cf 03 00 00       	jmp    f010596e <syscall+0x64e>
	if ( (r=envid2env(srcenvid, &srcenv, 1)) != 0 )
f010559f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01055a6:	00 
f01055a7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01055aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01055b1:	89 04 24             	mov    %eax,(%esp)
f01055b4:	e8 ae e4 ff ff       	call   f0103a67 <envid2env>
		return r;
f01055b9:	89 c2                	mov    %eax,%edx
	if ( (r=envid2env(srcenvid, &srcenv, 1)) != 0 )
f01055bb:	85 c0                	test   %eax,%eax
f01055bd:	0f 85 e2 00 00 00    	jne    f01056a5 <syscall+0x385>
	if ( (r=envid2env(dstenvid, &dstenv, 1)) != 0 )
f01055c3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01055ca:	00 
f01055cb:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01055ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01055d5:	89 04 24             	mov    %eax,(%esp)
f01055d8:	e8 8a e4 ff ff       	call   f0103a67 <envid2env>
		return r;
f01055dd:	89 c2                	mov    %eax,%edx
	if ( (r=envid2env(dstenvid, &dstenv, 1)) != 0 )
f01055df:	85 c0                	test   %eax,%eax
f01055e1:	0f 85 be 00 00 00    	jne    f01056a5 <syscall+0x385>
	if ((uint32_t)srcva >= UTOP || ((uintptr_t)srcva % PGSIZE != 0))
f01055e7:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01055ee:	77 7f                	ja     f010566f <syscall+0x34f>
f01055f0:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01055f7:	75 7d                	jne    f0105676 <syscall+0x356>
	if ((uint32_t)dstva >= UTOP || ((uintptr_t)dstva % PGSIZE != 0))
f01055f9:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105600:	77 7b                	ja     f010567d <syscall+0x35d>
f0105602:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105609:	75 79                	jne    f0105684 <syscall+0x364>
	if ((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
f010560b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010560e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105612:	8b 45 10             	mov    0x10(%ebp),%eax
f0105615:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105619:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010561c:	8b 40 60             	mov    0x60(%eax),%eax
f010561f:	89 04 24             	mov    %eax,(%esp)
f0105622:	e8 dd c0 ff ff       	call   f0101704 <page_lookup>
f0105627:	85 c0                	test   %eax,%eax
f0105629:	74 60                	je     f010568b <syscall+0x36b>
	if((perm & PTE_W) && ((*pte & PTE_W)==0))
f010562b:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010562f:	0f 84 d6 02 00 00    	je     f010590b <syscall+0x5eb>
f0105635:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105638:	f6 02 02             	testb  $0x2,(%edx)
f010563b:	0f 85 dc 02 00 00    	jne    f010591d <syscall+0x5fd>
f0105641:	eb 4f                	jmp    f0105692 <syscall+0x372>
	if ((r=page_insert(dstenv->env_pgdir, pp, dstva, perm)) < 0)
f0105643:	8b 75 1c             	mov    0x1c(%ebp),%esi
f0105646:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010564a:	8b 4d 18             	mov    0x18(%ebp),%ecx
f010564d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105651:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105655:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105658:	8b 40 60             	mov    0x60(%eax),%eax
f010565b:	89 04 24             	mov    %eax,(%esp)
f010565e:	e8 98 c1 ff ff       	call   f01017fb <page_insert>
f0105663:	85 c0                	test   %eax,%eax
f0105665:	ba 00 00 00 00       	mov    $0x0,%edx
f010566a:	0f 4e d0             	cmovle %eax,%edx
f010566d:	eb 36                	jmp    f01056a5 <syscall+0x385>
		return -E_INVAL;
f010566f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105674:	eb 2f                	jmp    f01056a5 <syscall+0x385>
f0105676:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010567b:	eb 28                	jmp    f01056a5 <syscall+0x385>
		return -E_INVAL;
f010567d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105682:	eb 21                	jmp    f01056a5 <syscall+0x385>
f0105684:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105689:	eb 1a                	jmp    f01056a5 <syscall+0x385>
		return -E_INVAL;
f010568b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105690:	eb 13                	jmp    f01056a5 <syscall+0x385>
		return -E_INVAL;
f0105692:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0105697:	eb 0c                	jmp    f01056a5 <syscall+0x385>
		return -E_INVAL;	
f0105699:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f010569e:	eb 05                	jmp    f01056a5 <syscall+0x385>
f01056a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
		case SYS_page_alloc: return sys_page_alloc(a1, (void *)a2, a3);
		case SYS_page_map: return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f01056a5:	89 d0                	mov    %edx,%eax
f01056a7:	e9 c2 02 00 00       	jmp    f010596e <syscall+0x64e>
	if ( (r = envid2env(envid, &e, 1)) != 0)	
f01056ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01056b3:	00 
f01056b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01056b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056be:	89 04 24             	mov    %eax,(%esp)
f01056c1:	e8 a1 e3 ff ff       	call   f0103a67 <envid2env>
		return r;	// -E_BAD_ENV
f01056c6:	89 c2                	mov    %eax,%edx
	if ( (r = envid2env(envid, &e, 1)) != 0)	
f01056c8:	85 c0                	test   %eax,%eax
f01056ca:	75 3a                	jne    f0105706 <syscall+0x3e6>
	if ((uint32_t)va >= UTOP || ((intptr_t) va % PGSIZE != 0))
f01056cc:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01056d3:	77 25                	ja     f01056fa <syscall+0x3da>
f01056d5:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01056dc:	75 23                	jne    f0105701 <syscall+0x3e1>
	page_remove(e->env_pgdir, va);
f01056de:	8b 45 10             	mov    0x10(%ebp),%eax
f01056e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056e8:	8b 40 60             	mov    0x60(%eax),%eax
f01056eb:	89 04 24             	mov    %eax,(%esp)
f01056ee:	e8 bf c0 ff ff       	call   f01017b2 <page_remove>
	return 0;
f01056f3:	ba 00 00 00 00       	mov    $0x0,%edx
f01056f8:	eb 0c                	jmp    f0105706 <syscall+0x3e6>
		return -E_INVAL;	
f01056fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f01056ff:	eb 05                	jmp    f0105706 <syscall+0x3e6>
f0105701:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
		case SYS_page_unmap: return sys_page_unmap(a1, (void *)a2);
f0105706:	89 d0                	mov    %edx,%eax
f0105708:	e9 61 02 00 00       	jmp    f010596e <syscall+0x64e>
	struct Env *e = NULL;
f010570d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if( envid2env(envid, &e, 1) < 0 )
f0105714:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010571b:	00 
f010571c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010571f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105723:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105726:	89 04 24             	mov    %eax,(%esp)
f0105729:	e8 39 e3 ff ff       	call   f0103a67 <envid2env>
f010572e:	85 c0                	test   %eax,%eax
f0105730:	78 13                	js     f0105745 <syscall+0x425>
	e->env_pgfault_upcall = func;
f0105732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105735:	8b 75 10             	mov    0x10(%ebp),%esi
f0105738:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f010573b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105740:	e9 29 02 00 00       	jmp    f010596e <syscall+0x64e>
		return -E_BAD_ENV;
f0105745:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		case SYS_env_set_pgfault_upcall: return sys_env_set_pgfault_upcall(a1, (void *)a2);
f010574a:	e9 1f 02 00 00       	jmp    f010596e <syscall+0x64e>
	if (dstva != (void *)(-1))
f010574f:	83 7d 0c ff          	cmpl   $0xffffffff,0xc(%ebp)
f0105753:	74 12                	je     f0105767 <syscall+0x447>
		if (((uintptr_t)dstva >= UTOP) || ((uintptr_t)dstva % PGSIZE != 0))
f0105755:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f010575c:	77 4e                	ja     f01057ac <syscall+0x48c>
f010575e:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0105765:	75 4f                	jne    f01057b6 <syscall+0x496>
	curenv->env_ipc_recving = 1;
f0105767:	e8 9d 14 00 00       	call   f0106c09 <cpunum>
f010576c:	6b c0 74             	imul   $0x74,%eax,%eax
f010576f:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105775:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0105779:	e8 8b 14 00 00       	call   f0106c09 <cpunum>
f010577e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105781:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105787:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010578a:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f010578d:	e8 77 14 00 00       	call   f0106c09 <cpunum>
f0105792:	6b c0 74             	imul   $0x74,%eax,%eax
f0105795:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f010579b:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	return 0;
f01057a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01057a7:	e9 c2 01 00 00       	jmp    f010596e <syscall+0x64e>
			return -E_INVAL;
f01057ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01057b1:	e9 b8 01 00 00       	jmp    f010596e <syscall+0x64e>
f01057b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_ipc_recv: return sys_ipc_recv((void *)a1);
f01057bb:	e9 ae 01 00 00       	jmp    f010596e <syscall+0x64e>
	if (envid2env(envid, &e, 0) < 0)
f01057c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01057c7:	00 
f01057c8:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01057cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057cf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057d2:	89 04 24             	mov    %eax,(%esp)
f01057d5:	e8 8d e2 ff ff       	call   f0103a67 <envid2env>
f01057da:	85 c0                	test   %eax,%eax
f01057dc:	0f 88 0d 01 00 00    	js     f01058ef <syscall+0x5cf>
	if ((e->env_status != ENV_NOT_RUNNABLE) || (e->env_ipc_recving == 0))
f01057e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01057e5:	83 7b 54 04          	cmpl   $0x4,0x54(%ebx)
f01057e9:	0f 85 07 01 00 00    	jne    f01058f6 <syscall+0x5d6>
f01057ef:	80 7b 68 00          	cmpb   $0x0,0x68(%ebx)
f01057f3:	0f 84 04 01 00 00    	je     f01058fd <syscall+0x5dd>
	bool transferring_pg = ((uintptr_t)srcva != -1) && ((uintptr_t)e->env_ipc_dstva != -1);
f01057f9:	83 7d 14 ff          	cmpl   $0xffffffff,0x14(%ebp)
f01057fd:	0f 84 40 01 00 00    	je     f0105943 <syscall+0x623>
f0105803:	83 7b 6c ff          	cmpl   $0xffffffff,0x6c(%ebx)
f0105807:	0f 85 22 01 00 00    	jne    f010592f <syscall+0x60f>
f010580d:	8d 76 00             	lea    0x0(%esi),%esi
f0105810:	e9 2e 01 00 00       	jmp    f0105943 <syscall+0x623>
			return -E_INVAL;
f0105815:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if(((uintptr_t)srcva >= UTOP) || ((uintptr_t)srcva % PGSIZE != 0))
f010581a:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0105821:	0f 85 47 01 00 00    	jne    f010596e <syscall+0x64e>
		if(((perm & PTE_U) != PTE_U) || ((perm & ~PTE_SYSCALL) != 0))
f0105827:	8b 55 18             	mov    0x18(%ebp),%edx
f010582a:	81 e2 fc f1 ff ff    	and    $0xfffff1fc,%edx
f0105830:	83 fa 04             	cmp    $0x4,%edx
f0105833:	0f 85 35 01 00 00    	jne    f010596e <syscall+0x64e>
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0105839:	e8 cb 13 00 00       	call   f0106c09 <cpunum>
f010583e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105841:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105845:	8b 75 14             	mov    0x14(%ebp),%esi
f0105848:	89 74 24 04          	mov    %esi,0x4(%esp)
f010584c:	6b c0 74             	imul   $0x74,%eax,%eax
f010584f:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105855:	8b 40 60             	mov    0x60(%eax),%eax
f0105858:	89 04 24             	mov    %eax,(%esp)
f010585b:	e8 a4 be ff ff       	call   f0101704 <page_lookup>
f0105860:	89 c2                	mov    %eax,%edx
		if(!pp)
f0105862:	85 c0                	test   %eax,%eax
f0105864:	74 64                	je     f01058ca <syscall+0x5aa>
		if((perm & PTE_W) && ((*pte & PTE_W) == 0))
f0105866:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010586a:	74 11                	je     f010587d <syscall+0x55d>
			return -E_INVAL;
f010586c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if((perm & PTE_W) && ((*pte & PTE_W) == 0))
f0105871:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105874:	f6 01 02             	testb  $0x2,(%ecx)
f0105877:	0f 84 f1 00 00 00    	je     f010596e <syscall+0x64e>
		if(page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm) < 0)
f010587d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105880:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105883:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105887:	8b 48 6c             	mov    0x6c(%eax),%ecx
f010588a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010588e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105892:	8b 40 60             	mov    0x60(%eax),%eax
f0105895:	89 04 24             	mov    %eax,(%esp)
f0105898:	e8 5e bf ff ff       	call   f01017fb <page_insert>
f010589d:	85 c0                	test   %eax,%eax
f010589f:	78 33                	js     f01058d4 <syscall+0x5b4>
	e->env_ipc_recving = 0;
f01058a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01058a4:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f01058a8:	e8 5c 13 00 00       	call   f0106c09 <cpunum>
f01058ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01058b0:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f01058b6:	8b 40 48             	mov    0x48(%eax),%eax
f01058b9:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f01058bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058bf:	8b 75 10             	mov    0x10(%ebp),%esi
f01058c2:	89 70 70             	mov    %esi,0x70(%eax)
	e->env_ipc_perm = (transferring_pg) ? perm : 0;
f01058c5:	8b 55 18             	mov    0x18(%ebp),%edx
f01058c8:	eb 14                	jmp    f01058de <syscall+0x5be>
			return -E_INVAL;
f01058ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01058cf:	e9 9a 00 00 00       	jmp    f010596e <syscall+0x64e>
			return -E_NO_MEM;
f01058d4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01058d9:	e9 90 00 00 00       	jmp    f010596e <syscall+0x64e>
	e->env_ipc_perm = (transferring_pg) ? perm : 0;
f01058de:	89 50 78             	mov    %edx,0x78(%eax)
	e->env_status = ENV_RUNNABLE;
f01058e1:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f01058e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01058ed:	eb 7f                	jmp    f010596e <syscall+0x64e>
		return -E_BAD_ENV;
f01058ef:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01058f4:	eb 78                	jmp    f010596e <syscall+0x64e>
		return -E_IPC_NOT_RECV;
f01058f6:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f01058fb:	eb 71                	jmp    f010596e <syscall+0x64e>
f01058fd:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_ipc_try_send: return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0105902:	eb 6a                	jmp    f010596e <syscall+0x64e>
		default:
			return -E_INVAL;
f0105904:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105909:	eb 63                	jmp    f010596e <syscall+0x64e>
	if ((perm & ~(PTE_SYSCALL)) != 0)
f010590b:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0105912:	0f 84 2b fd ff ff    	je     f0105643 <syscall+0x323>
f0105918:	e9 7c fd ff ff       	jmp    f0105699 <syscall+0x379>
f010591d:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0105924:	0f 84 19 fd ff ff    	je     f0105643 <syscall+0x323>
f010592a:	e9 71 fd ff ff       	jmp    f01056a0 <syscall+0x380>
			return -E_INVAL;
f010592f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if(((uintptr_t)srcva >= UTOP) || ((uintptr_t)srcva % PGSIZE != 0))
f0105934:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f010593b:	0f 86 d4 fe ff ff    	jbe    f0105815 <syscall+0x4f5>
f0105941:	eb 2b                	jmp    f010596e <syscall+0x64e>
	e->env_ipc_recving = 0;
f0105943:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f0105947:	e8 bd 12 00 00       	call   f0106c09 <cpunum>
f010594c:	6b c0 74             	imul   $0x74,%eax,%eax
f010594f:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105955:	8b 40 48             	mov    0x48(%eax),%eax
f0105958:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f010595b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010595e:	8b 75 10             	mov    0x10(%ebp),%esi
f0105961:	89 70 70             	mov    %esi,0x70(%eax)
	e->env_ipc_perm = (transferring_pg) ? perm : 0;
f0105964:	ba 00 00 00 00       	mov    $0x0,%edx
f0105969:	e9 70 ff ff ff       	jmp    f01058de <syscall+0x5be>
	}
}
f010596e:	83 c4 2c             	add    $0x2c,%esp
f0105971:	5b                   	pop    %ebx
f0105972:	5e                   	pop    %esi
f0105973:	5f                   	pop    %edi
f0105974:	5d                   	pop    %ebp
f0105975:	c3                   	ret    

f0105976 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105976:	55                   	push   %ebp
f0105977:	89 e5                	mov    %esp,%ebp
f0105979:	57                   	push   %edi
f010597a:	56                   	push   %esi
f010597b:	53                   	push   %ebx
f010597c:	83 ec 14             	sub    $0x14,%esp
f010597f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105982:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105985:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105988:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010598b:	8b 1a                	mov    (%edx),%ebx
f010598d:	8b 01                	mov    (%ecx),%eax
f010598f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105992:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0105999:	e9 88 00 00 00       	jmp    f0105a26 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f010599e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01059a1:	01 d8                	add    %ebx,%eax
f01059a3:	89 c7                	mov    %eax,%edi
f01059a5:	c1 ef 1f             	shr    $0x1f,%edi
f01059a8:	01 c7                	add    %eax,%edi
f01059aa:	d1 ff                	sar    %edi
f01059ac:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01059af:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01059b2:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01059b5:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01059b7:	eb 03                	jmp    f01059bc <stab_binsearch+0x46>
			m--;
f01059b9:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01059bc:	39 c3                	cmp    %eax,%ebx
f01059be:	7f 1f                	jg     f01059df <stab_binsearch+0x69>
f01059c0:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01059c4:	83 ea 0c             	sub    $0xc,%edx
f01059c7:	39 f1                	cmp    %esi,%ecx
f01059c9:	75 ee                	jne    f01059b9 <stab_binsearch+0x43>
f01059cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01059ce:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01059d1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01059d4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01059d8:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01059db:	76 18                	jbe    f01059f5 <stab_binsearch+0x7f>
f01059dd:	eb 05                	jmp    f01059e4 <stab_binsearch+0x6e>
			l = true_m + 1;
f01059df:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01059e2:	eb 42                	jmp    f0105a26 <stab_binsearch+0xb0>
			*region_left = m;
f01059e4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01059e7:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01059e9:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01059ec:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01059f3:	eb 31                	jmp    f0105a26 <stab_binsearch+0xb0>
		} else if (stabs[m].n_value > addr) {
f01059f5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01059f8:	73 17                	jae    f0105a11 <stab_binsearch+0x9b>
			*region_right = m - 1;
f01059fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01059fd:	83 e8 01             	sub    $0x1,%eax
f0105a00:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105a03:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105a06:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0105a08:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105a0f:	eb 15                	jmp    f0105a26 <stab_binsearch+0xb0>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105a11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a14:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105a17:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0105a19:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105a1d:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0105a1f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0105a26:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105a29:	0f 8e 6f ff ff ff    	jle    f010599e <stab_binsearch+0x28>
		}
	}

	if (!any_matches)
f0105a2f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105a33:	75 0f                	jne    f0105a44 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0105a35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a38:	8b 00                	mov    (%eax),%eax
f0105a3a:	83 e8 01             	sub    $0x1,%eax
f0105a3d:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105a40:	89 07                	mov    %eax,(%edi)
f0105a42:	eb 2c                	jmp    f0105a70 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105a44:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a47:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105a49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a4c:	8b 0f                	mov    (%edi),%ecx
f0105a4e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105a51:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0105a54:	8d 14 97             	lea    (%edi,%edx,4),%edx
		for (l = *region_right;
f0105a57:	eb 03                	jmp    f0105a5c <stab_binsearch+0xe6>
		     l--)
f0105a59:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0105a5c:	39 c8                	cmp    %ecx,%eax
f0105a5e:	7e 0b                	jle    f0105a6b <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0105a60:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0105a64:	83 ea 0c             	sub    $0xc,%edx
f0105a67:	39 f3                	cmp    %esi,%ebx
f0105a69:	75 ee                	jne    f0105a59 <stab_binsearch+0xe3>
			/* do nothing */;
		*region_left = l;
f0105a6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105a6e:	89 07                	mov    %eax,(%edi)
	}
}
f0105a70:	83 c4 14             	add    $0x14,%esp
f0105a73:	5b                   	pop    %ebx
f0105a74:	5e                   	pop    %esi
f0105a75:	5f                   	pop    %edi
f0105a76:	5d                   	pop    %ebp
f0105a77:	c3                   	ret    

f0105a78 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105a78:	55                   	push   %ebp
f0105a79:	89 e5                	mov    %esp,%ebp
f0105a7b:	57                   	push   %edi
f0105a7c:	56                   	push   %esi
f0105a7d:	53                   	push   %ebx
f0105a7e:	83 ec 4c             	sub    $0x4c,%esp
f0105a81:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a84:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105a87:	c7 07 34 8e 10 f0    	movl   $0xf0108e34,(%edi)
	info->eip_line = 0;
f0105a8d:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0105a94:	c7 47 08 34 8e 10 f0 	movl   $0xf0108e34,0x8(%edi)
	info->eip_fn_namelen = 9;
f0105a9b:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0105aa2:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f0105aa5:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105aac:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105ab2:	0f 87 ca 00 00 00    	ja     f0105b82 <debuginfo_eip+0x10a>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
f0105ab8:	e8 4c 11 00 00       	call   f0106c09 <cpunum>
f0105abd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105ac4:	00 
f0105ac5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105acc:	00 
f0105acd:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105ad4:	00 
f0105ad5:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ad8:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105ade:	89 04 24             	mov    %eax,(%esp)
f0105ae1:	e8 cd dd ff ff       	call   f01038b3 <user_mem_check>
f0105ae6:	85 c0                	test   %eax,%eax
f0105ae8:	0f 88 5a 02 00 00    	js     f0105d48 <debuginfo_eip+0x2d0>
			return -1;

		stabs = usd->stabs;
f0105aee:	a1 00 00 20 00       	mov    0x200000,%eax
f0105af3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0105af6:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0105afc:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0105b02:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105b05:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0105b0a:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0)
f0105b0d:	e8 f7 10 00 00       	call   f0106c09 <cpunum>
f0105b12:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105b19:	00 
f0105b1a:	89 da                	mov    %ebx,%edx
f0105b1c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105b1f:	29 ca                	sub    %ecx,%edx
f0105b21:	c1 fa 02             	sar    $0x2,%edx
f0105b24:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0105b2a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105b2e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105b32:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b35:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105b3b:	89 04 24             	mov    %eax,(%esp)
f0105b3e:	e8 70 dd ff ff       	call   f01038b3 <user_mem_check>
f0105b43:	85 c0                	test   %eax,%eax
f0105b45:	0f 88 04 02 00 00    	js     f0105d4f <debuginfo_eip+0x2d7>
			return -1;
			
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0105b4b:	e8 b9 10 00 00       	call   f0106c09 <cpunum>
f0105b50:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105b57:	00 
f0105b58:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105b5b:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105b5e:	29 ca                	sub    %ecx,%edx
f0105b60:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105b64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105b68:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b6b:	8b 80 28 20 23 f0    	mov    -0xfdcdfd8(%eax),%eax
f0105b71:	89 04 24             	mov    %eax,(%esp)
f0105b74:	e8 3a dd ff ff       	call   f01038b3 <user_mem_check>
f0105b79:	85 c0                	test   %eax,%eax
f0105b7b:	79 1f                	jns    f0105b9c <debuginfo_eip+0x124>
f0105b7d:	e9 d4 01 00 00       	jmp    f0105d56 <debuginfo_eip+0x2de>
		stabstr_end = __STABSTR_END__;
f0105b82:	c7 45 bc ff 79 11 f0 	movl   $0xf01179ff,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105b89:	c7 45 c0 29 42 11 f0 	movl   $0xf0114229,-0x40(%ebp)
		stab_end = __STAB_END__;
f0105b90:	bb 28 42 11 f0       	mov    $0xf0114228,%ebx
		stabs = __STAB_BEGIN__;
f0105b95:	c7 45 c4 14 93 10 f0 	movl   $0xf0109314,-0x3c(%ebp)
			return -1;

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105b9c:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105b9f:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0105ba2:	0f 83 b5 01 00 00    	jae    f0105d5d <debuginfo_eip+0x2e5>
f0105ba8:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105bac:	0f 85 b2 01 00 00    	jne    f0105d64 <debuginfo_eip+0x2ec>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105bb2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105bb9:	2b 5d c4             	sub    -0x3c(%ebp),%ebx
f0105bbc:	c1 fb 02             	sar    $0x2,%ebx
f0105bbf:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0105bc5:	83 e8 01             	sub    $0x1,%eax
f0105bc8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105bcb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105bcf:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105bd6:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105bd9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105bdc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0105bdf:	89 d8                	mov    %ebx,%eax
f0105be1:	e8 90 fd ff ff       	call   f0105976 <stab_binsearch>
	if (lfile == 0)
f0105be6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105be9:	85 c0                	test   %eax,%eax
f0105beb:	0f 84 7a 01 00 00    	je     f0105d6b <debuginfo_eip+0x2f3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105bf1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105bf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105bf7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105bfa:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105bfe:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105c05:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105c08:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105c0b:	89 d8                	mov    %ebx,%eax
f0105c0d:	e8 64 fd ff ff       	call   f0105976 <stab_binsearch>

	if (lfun <= rfun) {
f0105c12:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105c15:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0105c18:	39 d8                	cmp    %ebx,%eax
f0105c1a:	7f 32                	jg     f0105c4e <debuginfo_eip+0x1d6>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105c1c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105c1f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105c22:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0105c25:	8b 0a                	mov    (%edx),%ecx
f0105c27:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0105c2a:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0105c2d:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f0105c30:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f0105c33:	73 09                	jae    f0105c3e <debuginfo_eip+0x1c6>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105c35:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0105c38:	03 4d c0             	add    -0x40(%ebp),%ecx
f0105c3b:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105c3e:	8b 52 08             	mov    0x8(%edx),%edx
f0105c41:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0105c44:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105c46:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105c49:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0105c4c:	eb 0f                	jmp    f0105c5d <debuginfo_eip+0x1e5>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105c4e:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f0105c51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c54:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105c57:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105c5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105c5d:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105c64:	00 
f0105c65:	8b 47 08             	mov    0x8(%edi),%eax
f0105c68:	89 04 24             	mov    %eax,(%esp)
f0105c6b:	e8 2b 09 00 00       	call   f010659b <strfind>
f0105c70:	2b 47 08             	sub    0x8(%edi),%eax
f0105c73:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105c76:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105c7a:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105c81:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105c84:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105c87:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105c8a:	89 f0                	mov    %esi,%eax
f0105c8c:	e8 e5 fc ff ff       	call   f0105976 <stab_binsearch>
	if (lline <= rline){
f0105c91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105c94:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105c97:	0f 8f d5 00 00 00    	jg     f0105d72 <debuginfo_eip+0x2fa>
		info->eip_line = stabs[lline].n_desc;
f0105c9d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105ca0:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0105ca5:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105ca8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105cab:	89 c3                	mov    %eax,%ebx
f0105cad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105cb0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105cb3:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105cb6:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105cb9:	89 df                	mov    %ebx,%edi
f0105cbb:	eb 06                	jmp    f0105cc3 <debuginfo_eip+0x24b>
f0105cbd:	83 e8 01             	sub    $0x1,%eax
f0105cc0:	83 ea 0c             	sub    $0xc,%edx
f0105cc3:	89 c6                	mov    %eax,%esi
f0105cc5:	39 c7                	cmp    %eax,%edi
f0105cc7:	7f 3c                	jg     f0105d05 <debuginfo_eip+0x28d>
	       && stabs[lline].n_type != N_SOL
f0105cc9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105ccd:	80 f9 84             	cmp    $0x84,%cl
f0105cd0:	75 08                	jne    f0105cda <debuginfo_eip+0x262>
f0105cd2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105cd5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105cd8:	eb 11                	jmp    f0105ceb <debuginfo_eip+0x273>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105cda:	80 f9 64             	cmp    $0x64,%cl
f0105cdd:	75 de                	jne    f0105cbd <debuginfo_eip+0x245>
f0105cdf:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105ce3:	74 d8                	je     f0105cbd <debuginfo_eip+0x245>
f0105ce5:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105ce8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105ceb:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105cee:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105cf1:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0105cf4:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105cf7:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105cfa:	39 d0                	cmp    %edx,%eax
f0105cfc:	73 0a                	jae    f0105d08 <debuginfo_eip+0x290>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105cfe:	03 45 c0             	add    -0x40(%ebp),%eax
f0105d01:	89 07                	mov    %eax,(%edi)
f0105d03:	eb 03                	jmp    f0105d08 <debuginfo_eip+0x290>
f0105d05:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105d08:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105d0b:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105d0e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0105d13:	39 da                	cmp    %ebx,%edx
f0105d15:	7d 67                	jge    f0105d7e <debuginfo_eip+0x306>
		for (lline = lfun + 1;
f0105d17:	83 c2 01             	add    $0x1,%edx
f0105d1a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105d1d:	89 d0                	mov    %edx,%eax
f0105d1f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105d22:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105d25:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105d28:	eb 04                	jmp    f0105d2e <debuginfo_eip+0x2b6>
			info->eip_fn_narg++;
f0105d2a:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f0105d2e:	39 c3                	cmp    %eax,%ebx
f0105d30:	7e 47                	jle    f0105d79 <debuginfo_eip+0x301>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105d32:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105d36:	83 c0 01             	add    $0x1,%eax
f0105d39:	83 c2 0c             	add    $0xc,%edx
f0105d3c:	80 f9 a0             	cmp    $0xa0,%cl
f0105d3f:	74 e9                	je     f0105d2a <debuginfo_eip+0x2b2>
	return 0;
f0105d41:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d46:	eb 36                	jmp    f0105d7e <debuginfo_eip+0x306>
			return -1;
f0105d48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d4d:	eb 2f                	jmp    f0105d7e <debuginfo_eip+0x306>
			return -1;
f0105d4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d54:	eb 28                	jmp    f0105d7e <debuginfo_eip+0x306>
			return -1;
f0105d56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d5b:	eb 21                	jmp    f0105d7e <debuginfo_eip+0x306>
		return -1;
f0105d5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d62:	eb 1a                	jmp    f0105d7e <debuginfo_eip+0x306>
f0105d64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d69:	eb 13                	jmp    f0105d7e <debuginfo_eip+0x306>
		return -1;
f0105d6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d70:	eb 0c                	jmp    f0105d7e <debuginfo_eip+0x306>
		return -1;
f0105d72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105d77:	eb 05                	jmp    f0105d7e <debuginfo_eip+0x306>
	return 0;
f0105d79:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d7e:	83 c4 4c             	add    $0x4c,%esp
f0105d81:	5b                   	pop    %ebx
f0105d82:	5e                   	pop    %esi
f0105d83:	5f                   	pop    %edi
f0105d84:	5d                   	pop    %ebp
f0105d85:	c3                   	ret    
f0105d86:	66 90                	xchg   %ax,%ax
f0105d88:	66 90                	xchg   %ax,%ax
f0105d8a:	66 90                	xchg   %ax,%ax
f0105d8c:	66 90                	xchg   %ax,%ax
f0105d8e:	66 90                	xchg   %ax,%ax

f0105d90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105d90:	55                   	push   %ebp
f0105d91:	89 e5                	mov    %esp,%ebp
f0105d93:	57                   	push   %edi
f0105d94:	56                   	push   %esi
f0105d95:	53                   	push   %ebx
f0105d96:	83 ec 3c             	sub    $0x3c,%esp
f0105d99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105d9c:	89 d7                	mov    %edx,%edi
f0105d9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105da1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105da4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105da7:	89 c3                	mov    %eax,%ebx
f0105da9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105dac:	8b 45 10             	mov    0x10(%ebp),%eax
f0105daf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105db2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105db7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105dba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105dbd:	39 d9                	cmp    %ebx,%ecx
f0105dbf:	72 05                	jb     f0105dc6 <printnum+0x36>
f0105dc1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105dc4:	77 69                	ja     f0105e2f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105dc6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105dc9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105dcd:	83 ee 01             	sub    $0x1,%esi
f0105dd0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105dd4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105dd8:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105ddc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105de0:	89 c3                	mov    %eax,%ebx
f0105de2:	89 d6                	mov    %edx,%esi
f0105de4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105de7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105dea:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105dee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105df2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105df5:	89 04 24             	mov    %eax,(%esp)
f0105df8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dff:	e8 4c 12 00 00       	call   f0107050 <__udivdi3>
f0105e04:	89 d9                	mov    %ebx,%ecx
f0105e06:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105e0a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105e0e:	89 04 24             	mov    %eax,(%esp)
f0105e11:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e15:	89 fa                	mov    %edi,%edx
f0105e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e1a:	e8 71 ff ff ff       	call   f0105d90 <printnum>
f0105e1f:	eb 1b                	jmp    f0105e3c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105e21:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e25:	8b 45 18             	mov    0x18(%ebp),%eax
f0105e28:	89 04 24             	mov    %eax,(%esp)
f0105e2b:	ff d3                	call   *%ebx
f0105e2d:	eb 03                	jmp    f0105e32 <printnum+0xa2>
f0105e2f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
f0105e32:	83 ee 01             	sub    $0x1,%esi
f0105e35:	85 f6                	test   %esi,%esi
f0105e37:	7f e8                	jg     f0105e21 <printnum+0x91>
f0105e39:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105e3c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e40:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105e44:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105e47:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105e4a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e4e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105e52:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105e55:	89 04 24             	mov    %eax,(%esp)
f0105e58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e5f:	e8 1c 13 00 00       	call   f0107180 <__umoddi3>
f0105e64:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e68:	0f be 80 3e 8e 10 f0 	movsbl -0xfef71c2(%eax),%eax
f0105e6f:	89 04 24             	mov    %eax,(%esp)
f0105e72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e75:	ff d0                	call   *%eax
}
f0105e77:	83 c4 3c             	add    $0x3c,%esp
f0105e7a:	5b                   	pop    %ebx
f0105e7b:	5e                   	pop    %esi
f0105e7c:	5f                   	pop    %edi
f0105e7d:	5d                   	pop    %ebp
f0105e7e:	c3                   	ret    

f0105e7f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105e7f:	55                   	push   %ebp
f0105e80:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105e82:	83 fa 01             	cmp    $0x1,%edx
f0105e85:	7e 0e                	jle    f0105e95 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105e87:	8b 10                	mov    (%eax),%edx
f0105e89:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105e8c:	89 08                	mov    %ecx,(%eax)
f0105e8e:	8b 02                	mov    (%edx),%eax
f0105e90:	8b 52 04             	mov    0x4(%edx),%edx
f0105e93:	eb 22                	jmp    f0105eb7 <getuint+0x38>
	else if (lflag)
f0105e95:	85 d2                	test   %edx,%edx
f0105e97:	74 10                	je     f0105ea9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105e99:	8b 10                	mov    (%eax),%edx
f0105e9b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105e9e:	89 08                	mov    %ecx,(%eax)
f0105ea0:	8b 02                	mov    (%edx),%eax
f0105ea2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ea7:	eb 0e                	jmp    f0105eb7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105ea9:	8b 10                	mov    (%eax),%edx
f0105eab:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105eae:	89 08                	mov    %ecx,(%eax)
f0105eb0:	8b 02                	mov    (%edx),%eax
f0105eb2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105eb7:	5d                   	pop    %ebp
f0105eb8:	c3                   	ret    

f0105eb9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105eb9:	55                   	push   %ebp
f0105eba:	89 e5                	mov    %esp,%ebp
f0105ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105ebf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105ec3:	8b 10                	mov    (%eax),%edx
f0105ec5:	3b 50 04             	cmp    0x4(%eax),%edx
f0105ec8:	73 0a                	jae    f0105ed4 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105eca:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105ecd:	89 08                	mov    %ecx,(%eax)
f0105ecf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ed2:	88 02                	mov    %al,(%edx)
}
f0105ed4:	5d                   	pop    %ebp
f0105ed5:	c3                   	ret    

f0105ed6 <printfmt>:
{
f0105ed6:	55                   	push   %ebp
f0105ed7:	89 e5                	mov    %esp,%ebp
f0105ed9:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
f0105edc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105edf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ee3:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ee6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105eea:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105eed:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ef1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ef4:	89 04 24             	mov    %eax,(%esp)
f0105ef7:	e8 02 00 00 00       	call   f0105efe <vprintfmt>
}
f0105efc:	c9                   	leave  
f0105efd:	c3                   	ret    

f0105efe <vprintfmt>:
{
f0105efe:	55                   	push   %ebp
f0105eff:	89 e5                	mov    %esp,%ebp
f0105f01:	57                   	push   %edi
f0105f02:	56                   	push   %esi
f0105f03:	53                   	push   %ebx
f0105f04:	83 ec 3c             	sub    $0x3c,%esp
f0105f07:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105f0d:	eb 14                	jmp    f0105f23 <vprintfmt+0x25>
			if (ch == '\0'){
f0105f0f:	85 c0                	test   %eax,%eax
f0105f11:	0f 84 b3 03 00 00    	je     f01062ca <vprintfmt+0x3cc>
			putch(ch, putdat);
f0105f17:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f1b:	89 04 24             	mov    %eax,(%esp)
f0105f1e:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105f21:	89 f3                	mov    %esi,%ebx
f0105f23:	8d 73 01             	lea    0x1(%ebx),%esi
f0105f26:	0f b6 03             	movzbl (%ebx),%eax
f0105f29:	83 f8 25             	cmp    $0x25,%eax
f0105f2c:	75 e1                	jne    f0105f0f <vprintfmt+0x11>
f0105f2e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105f32:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105f39:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105f40:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105f47:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f4c:	eb 1d                	jmp    f0105f6b <vprintfmt+0x6d>
		switch (ch = *(unsigned char *) fmt++) {
f0105f4e:	89 de                	mov    %ebx,%esi
			padc = '-';
f0105f50:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105f54:	eb 15                	jmp    f0105f6b <vprintfmt+0x6d>
		switch (ch = *(unsigned char *) fmt++) {
f0105f56:	89 de                	mov    %ebx,%esi
			padc = '0';
f0105f58:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105f5c:	eb 0d                	jmp    f0105f6b <vprintfmt+0x6d>
				width = precision, precision = -1;
f0105f5e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105f61:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105f64:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105f6b:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105f6e:	0f b6 0e             	movzbl (%esi),%ecx
f0105f71:	0f b6 c1             	movzbl %cl,%eax
f0105f74:	83 e9 23             	sub    $0x23,%ecx
f0105f77:	80 f9 55             	cmp    $0x55,%cl
f0105f7a:	0f 87 2a 03 00 00    	ja     f01062aa <vprintfmt+0x3ac>
f0105f80:	0f b6 c9             	movzbl %cl,%ecx
f0105f83:	ff 24 8d 00 8f 10 f0 	jmp    *-0xfef7100(,%ecx,4)
f0105f8a:	89 de                	mov    %ebx,%esi
f0105f8c:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
f0105f91:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105f94:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0105f98:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105f9b:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105f9e:	83 fb 09             	cmp    $0x9,%ebx
f0105fa1:	77 36                	ja     f0105fd9 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
f0105fa3:	83 c6 01             	add    $0x1,%esi
			}
f0105fa6:	eb e9                	jmp    f0105f91 <vprintfmt+0x93>
			precision = va_arg(ap, int);
f0105fa8:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fab:	8d 48 04             	lea    0x4(%eax),%ecx
f0105fae:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105fb1:	8b 00                	mov    (%eax),%eax
f0105fb3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105fb6:	89 de                	mov    %ebx,%esi
			goto process_precision;
f0105fb8:	eb 22                	jmp    f0105fdc <vprintfmt+0xde>
f0105fba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105fbd:	85 c9                	test   %ecx,%ecx
f0105fbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fc4:	0f 49 c1             	cmovns %ecx,%eax
f0105fc7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105fca:	89 de                	mov    %ebx,%esi
f0105fcc:	eb 9d                	jmp    f0105f6b <vprintfmt+0x6d>
f0105fce:	89 de                	mov    %ebx,%esi
			altflag = 1;
f0105fd0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0105fd7:	eb 92                	jmp    f0105f6b <vprintfmt+0x6d>
f0105fd9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
f0105fdc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105fe0:	79 89                	jns    f0105f6b <vprintfmt+0x6d>
f0105fe2:	e9 77 ff ff ff       	jmp    f0105f5e <vprintfmt+0x60>
			lflag++;
f0105fe7:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
f0105fea:	89 de                	mov    %ebx,%esi
			goto reswitch;
f0105fec:	e9 7a ff ff ff       	jmp    f0105f6b <vprintfmt+0x6d>
			putch(va_arg(ap, int), putdat);
f0105ff1:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ff4:	8d 50 04             	lea    0x4(%eax),%edx
f0105ff7:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ffa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ffe:	8b 00                	mov    (%eax),%eax
f0106000:	89 04 24             	mov    %eax,(%esp)
f0106003:	ff 55 08             	call   *0x8(%ebp)
			break;
f0106006:	e9 18 ff ff ff       	jmp    f0105f23 <vprintfmt+0x25>
			err = va_arg(ap, int);
f010600b:	8b 45 14             	mov    0x14(%ebp),%eax
f010600e:	8d 50 04             	lea    0x4(%eax),%edx
f0106011:	89 55 14             	mov    %edx,0x14(%ebp)
f0106014:	8b 00                	mov    (%eax),%eax
f0106016:	99                   	cltd   
f0106017:	31 d0                	xor    %edx,%eax
f0106019:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010601b:	83 f8 08             	cmp    $0x8,%eax
f010601e:	7f 0b                	jg     f010602b <vprintfmt+0x12d>
f0106020:	8b 14 85 60 90 10 f0 	mov    -0xfef6fa0(,%eax,4),%edx
f0106027:	85 d2                	test   %edx,%edx
f0106029:	75 20                	jne    f010604b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f010602b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010602f:	c7 44 24 08 56 8e 10 	movl   $0xf0108e56,0x8(%esp)
f0106036:	f0 
f0106037:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010603b:	8b 45 08             	mov    0x8(%ebp),%eax
f010603e:	89 04 24             	mov    %eax,(%esp)
f0106041:	e8 90 fe ff ff       	call   f0105ed6 <printfmt>
f0106046:	e9 d8 fe ff ff       	jmp    f0105f23 <vprintfmt+0x25>
				printfmt(putch, putdat, "%s", p);
f010604b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010604f:	c7 44 24 08 27 7c 10 	movl   $0xf0107c27,0x8(%esp)
f0106056:	f0 
f0106057:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010605b:	8b 45 08             	mov    0x8(%ebp),%eax
f010605e:	89 04 24             	mov    %eax,(%esp)
f0106061:	e8 70 fe ff ff       	call   f0105ed6 <printfmt>
f0106066:	e9 b8 fe ff ff       	jmp    f0105f23 <vprintfmt+0x25>
		switch (ch = *(unsigned char *) fmt++) {
f010606b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010606e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106071:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
f0106074:	8b 45 14             	mov    0x14(%ebp),%eax
f0106077:	8d 50 04             	lea    0x4(%eax),%edx
f010607a:	89 55 14             	mov    %edx,0x14(%ebp)
f010607d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f010607f:	85 f6                	test   %esi,%esi
f0106081:	b8 4f 8e 10 f0       	mov    $0xf0108e4f,%eax
f0106086:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0106089:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f010608d:	0f 84 97 00 00 00    	je     f010612a <vprintfmt+0x22c>
f0106093:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0106097:	0f 8e 9b 00 00 00    	jle    f0106138 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f010609d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01060a1:	89 34 24             	mov    %esi,(%esp)
f01060a4:	e8 9f 03 00 00       	call   f0106448 <strnlen>
f01060a9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01060ac:	29 c2                	sub    %eax,%edx
f01060ae:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f01060b1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01060b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01060b8:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01060bb:	8b 75 08             	mov    0x8(%ebp),%esi
f01060be:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01060c1:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
f01060c3:	eb 0f                	jmp    f01060d4 <vprintfmt+0x1d6>
					putch(padc, putdat);
f01060c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01060c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01060cc:	89 04 24             	mov    %eax,(%esp)
f01060cf:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01060d1:	83 eb 01             	sub    $0x1,%ebx
f01060d4:	85 db                	test   %ebx,%ebx
f01060d6:	7f ed                	jg     f01060c5 <vprintfmt+0x1c7>
f01060d8:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01060db:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01060de:	85 d2                	test   %edx,%edx
f01060e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01060e5:	0f 49 c2             	cmovns %edx,%eax
f01060e8:	29 c2                	sub    %eax,%edx
f01060ea:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01060ed:	89 d7                	mov    %edx,%edi
f01060ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01060f2:	eb 50                	jmp    f0106144 <vprintfmt+0x246>
				if (altflag && (ch < ' ' || ch > '~'))
f01060f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01060f8:	74 1e                	je     f0106118 <vprintfmt+0x21a>
f01060fa:	0f be d2             	movsbl %dl,%edx
f01060fd:	83 ea 20             	sub    $0x20,%edx
f0106100:	83 fa 5e             	cmp    $0x5e,%edx
f0106103:	76 13                	jbe    f0106118 <vprintfmt+0x21a>
					putch('?', putdat);
f0106105:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106108:	89 44 24 04          	mov    %eax,0x4(%esp)
f010610c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0106113:	ff 55 08             	call   *0x8(%ebp)
f0106116:	eb 0d                	jmp    f0106125 <vprintfmt+0x227>
					putch(ch, putdat);
f0106118:	8b 55 0c             	mov    0xc(%ebp),%edx
f010611b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010611f:	89 04 24             	mov    %eax,(%esp)
f0106122:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106125:	83 ef 01             	sub    $0x1,%edi
f0106128:	eb 1a                	jmp    f0106144 <vprintfmt+0x246>
f010612a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010612d:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0106130:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106133:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0106136:	eb 0c                	jmp    f0106144 <vprintfmt+0x246>
f0106138:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010613b:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010613e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106141:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0106144:	83 c6 01             	add    $0x1,%esi
f0106147:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f010614b:	0f be c2             	movsbl %dl,%eax
f010614e:	85 c0                	test   %eax,%eax
f0106150:	74 27                	je     f0106179 <vprintfmt+0x27b>
f0106152:	85 db                	test   %ebx,%ebx
f0106154:	78 9e                	js     f01060f4 <vprintfmt+0x1f6>
f0106156:	83 eb 01             	sub    $0x1,%ebx
f0106159:	79 99                	jns    f01060f4 <vprintfmt+0x1f6>
f010615b:	89 f8                	mov    %edi,%eax
f010615d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106160:	8b 75 08             	mov    0x8(%ebp),%esi
f0106163:	89 c3                	mov    %eax,%ebx
f0106165:	eb 1a                	jmp    f0106181 <vprintfmt+0x283>
				putch(' ', putdat);
f0106167:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010616b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106172:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0106174:	83 eb 01             	sub    $0x1,%ebx
f0106177:	eb 08                	jmp    f0106181 <vprintfmt+0x283>
f0106179:	89 fb                	mov    %edi,%ebx
f010617b:	8b 75 08             	mov    0x8(%ebp),%esi
f010617e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106181:	85 db                	test   %ebx,%ebx
f0106183:	7f e2                	jg     f0106167 <vprintfmt+0x269>
f0106185:	89 75 08             	mov    %esi,0x8(%ebp)
f0106188:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010618b:	e9 93 fd ff ff       	jmp    f0105f23 <vprintfmt+0x25>
	if (lflag >= 2)
f0106190:	83 fa 01             	cmp    $0x1,%edx
f0106193:	7e 16                	jle    f01061ab <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f0106195:	8b 45 14             	mov    0x14(%ebp),%eax
f0106198:	8d 50 08             	lea    0x8(%eax),%edx
f010619b:	89 55 14             	mov    %edx,0x14(%ebp)
f010619e:	8b 50 04             	mov    0x4(%eax),%edx
f01061a1:	8b 00                	mov    (%eax),%eax
f01061a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01061a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01061a9:	eb 32                	jmp    f01061dd <vprintfmt+0x2df>
	else if (lflag)
f01061ab:	85 d2                	test   %edx,%edx
f01061ad:	74 18                	je     f01061c7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f01061af:	8b 45 14             	mov    0x14(%ebp),%eax
f01061b2:	8d 50 04             	lea    0x4(%eax),%edx
f01061b5:	89 55 14             	mov    %edx,0x14(%ebp)
f01061b8:	8b 30                	mov    (%eax),%esi
f01061ba:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01061bd:	89 f0                	mov    %esi,%eax
f01061bf:	c1 f8 1f             	sar    $0x1f,%eax
f01061c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01061c5:	eb 16                	jmp    f01061dd <vprintfmt+0x2df>
		return va_arg(*ap, int);
f01061c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01061ca:	8d 50 04             	lea    0x4(%eax),%edx
f01061cd:	89 55 14             	mov    %edx,0x14(%ebp)
f01061d0:	8b 30                	mov    (%eax),%esi
f01061d2:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01061d5:	89 f0                	mov    %esi,%eax
f01061d7:	c1 f8 1f             	sar    $0x1f,%eax
f01061da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
f01061dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01061e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
f01061e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
f01061e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01061ec:	0f 89 80 00 00 00    	jns    f0106272 <vprintfmt+0x374>
				putch('-', putdat);
f01061f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01061f6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01061fd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0106200:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106203:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106206:	f7 d8                	neg    %eax
f0106208:	83 d2 00             	adc    $0x0,%edx
f010620b:	f7 da                	neg    %edx
			base = 10;
f010620d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0106212:	eb 5e                	jmp    f0106272 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f0106214:	8d 45 14             	lea    0x14(%ebp),%eax
f0106217:	e8 63 fc ff ff       	call   f0105e7f <getuint>
			base = 10;
f010621c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0106221:	eb 4f                	jmp    f0106272 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f0106223:	8d 45 14             	lea    0x14(%ebp),%eax
f0106226:	e8 54 fc ff ff       	call   f0105e7f <getuint>
      		base = 8;
f010622b:	b9 08 00 00 00       	mov    $0x8,%ecx
      		goto number;
f0106230:	eb 40                	jmp    f0106272 <vprintfmt+0x374>
			putch('0', putdat);
f0106232:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106236:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010623d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0106240:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106244:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010624b:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
f010624e:	8b 45 14             	mov    0x14(%ebp),%eax
f0106251:	8d 50 04             	lea    0x4(%eax),%edx
f0106254:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
f0106257:	8b 00                	mov    (%eax),%eax
f0106259:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
f010625e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0106263:	eb 0d                	jmp    f0106272 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f0106265:	8d 45 14             	lea    0x14(%ebp),%eax
f0106268:	e8 12 fc ff ff       	call   f0105e7f <getuint>
			base = 16;
f010626d:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
f0106272:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0106276:	89 74 24 10          	mov    %esi,0x10(%esp)
f010627a:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010627d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106281:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106285:	89 04 24             	mov    %eax,(%esp)
f0106288:	89 54 24 04          	mov    %edx,0x4(%esp)
f010628c:	89 fa                	mov    %edi,%edx
f010628e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106291:	e8 fa fa ff ff       	call   f0105d90 <printnum>
			break;
f0106296:	e9 88 fc ff ff       	jmp    f0105f23 <vprintfmt+0x25>
			putch(ch, putdat);
f010629b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010629f:	89 04 24             	mov    %eax,(%esp)
f01062a2:	ff 55 08             	call   *0x8(%ebp)
			break;
f01062a5:	e9 79 fc ff ff       	jmp    f0105f23 <vprintfmt+0x25>
			putch('%', putdat);
f01062aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01062ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01062b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01062b8:	89 f3                	mov    %esi,%ebx
f01062ba:	eb 03                	jmp    f01062bf <vprintfmt+0x3c1>
f01062bc:	83 eb 01             	sub    $0x1,%ebx
f01062bf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01062c3:	75 f7                	jne    f01062bc <vprintfmt+0x3be>
f01062c5:	e9 59 fc ff ff       	jmp    f0105f23 <vprintfmt+0x25>
}
f01062ca:	83 c4 3c             	add    $0x3c,%esp
f01062cd:	5b                   	pop    %ebx
f01062ce:	5e                   	pop    %esi
f01062cf:	5f                   	pop    %edi
f01062d0:	5d                   	pop    %ebp
f01062d1:	c3                   	ret    

f01062d2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01062d2:	55                   	push   %ebp
f01062d3:	89 e5                	mov    %esp,%ebp
f01062d5:	83 ec 28             	sub    $0x28,%esp
f01062d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01062db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01062de:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01062e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01062e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01062e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01062ef:	85 c0                	test   %eax,%eax
f01062f1:	74 30                	je     f0106323 <vsnprintf+0x51>
f01062f3:	85 d2                	test   %edx,%edx
f01062f5:	7e 2c                	jle    f0106323 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01062f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01062fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01062fe:	8b 45 10             	mov    0x10(%ebp),%eax
f0106301:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106305:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0106308:	89 44 24 04          	mov    %eax,0x4(%esp)
f010630c:	c7 04 24 b9 5e 10 f0 	movl   $0xf0105eb9,(%esp)
f0106313:	e8 e6 fb ff ff       	call   f0105efe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0106318:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010631b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010631e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106321:	eb 05                	jmp    f0106328 <vsnprintf+0x56>
		return -E_INVAL;
f0106323:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f0106328:	c9                   	leave  
f0106329:	c3                   	ret    

f010632a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010632a:	55                   	push   %ebp
f010632b:	89 e5                	mov    %esp,%ebp
f010632d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0106330:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0106333:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106337:	8b 45 10             	mov    0x10(%ebp),%eax
f010633a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010633e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106341:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106345:	8b 45 08             	mov    0x8(%ebp),%eax
f0106348:	89 04 24             	mov    %eax,(%esp)
f010634b:	e8 82 ff ff ff       	call   f01062d2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0106350:	c9                   	leave  
f0106351:	c3                   	ret    
f0106352:	66 90                	xchg   %ax,%ax
f0106354:	66 90                	xchg   %ax,%ax
f0106356:	66 90                	xchg   %ax,%ax
f0106358:	66 90                	xchg   %ax,%ax
f010635a:	66 90                	xchg   %ax,%ax
f010635c:	66 90                	xchg   %ax,%ax
f010635e:	66 90                	xchg   %ax,%ax

f0106360 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106360:	55                   	push   %ebp
f0106361:	89 e5                	mov    %esp,%ebp
f0106363:	57                   	push   %edi
f0106364:	56                   	push   %esi
f0106365:	53                   	push   %ebx
f0106366:	83 ec 1c             	sub    $0x1c,%esp
f0106369:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010636c:	85 c0                	test   %eax,%eax
f010636e:	74 10                	je     f0106380 <readline+0x20>
		cprintf("%s", prompt);
f0106370:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106374:	c7 04 24 27 7c 10 f0 	movl   $0xf0107c27,(%esp)
f010637b:	e8 d0 df ff ff       	call   f0104350 <cprintf>

	i = 0;
	echoing = iscons(0);
f0106380:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106387:	e8 0f a4 ff ff       	call   f010079b <iscons>
f010638c:	89 c7                	mov    %eax,%edi
	i = 0;
f010638e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0106393:	e8 f2 a3 ff ff       	call   f010078a <getchar>
f0106398:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010639a:	85 c0                	test   %eax,%eax
f010639c:	79 17                	jns    f01063b5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010639e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063a2:	c7 04 24 84 90 10 f0 	movl   $0xf0109084,(%esp)
f01063a9:	e8 a2 df ff ff       	call   f0104350 <cprintf>
			return NULL;
f01063ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01063b3:	eb 6d                	jmp    f0106422 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01063b5:	83 f8 7f             	cmp    $0x7f,%eax
f01063b8:	74 05                	je     f01063bf <readline+0x5f>
f01063ba:	83 f8 08             	cmp    $0x8,%eax
f01063bd:	75 19                	jne    f01063d8 <readline+0x78>
f01063bf:	85 f6                	test   %esi,%esi
f01063c1:	7e 15                	jle    f01063d8 <readline+0x78>
			if (echoing)
f01063c3:	85 ff                	test   %edi,%edi
f01063c5:	74 0c                	je     f01063d3 <readline+0x73>
				cputchar('\b');
f01063c7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01063ce:	e8 a7 a3 ff ff       	call   f010077a <cputchar>
			i--;
f01063d3:	83 ee 01             	sub    $0x1,%esi
f01063d6:	eb bb                	jmp    f0106393 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01063d8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01063de:	7f 1c                	jg     f01063fc <readline+0x9c>
f01063e0:	83 fb 1f             	cmp    $0x1f,%ebx
f01063e3:	7e 17                	jle    f01063fc <readline+0x9c>
			if (echoing)
f01063e5:	85 ff                	test   %edi,%edi
f01063e7:	74 08                	je     f01063f1 <readline+0x91>
				cputchar(c);
f01063e9:	89 1c 24             	mov    %ebx,(%esp)
f01063ec:	e8 89 a3 ff ff       	call   f010077a <cputchar>
			buf[i++] = c;
f01063f1:	88 9e 80 1a 23 f0    	mov    %bl,-0xfdce580(%esi)
f01063f7:	8d 76 01             	lea    0x1(%esi),%esi
f01063fa:	eb 97                	jmp    f0106393 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01063fc:	83 fb 0d             	cmp    $0xd,%ebx
f01063ff:	74 05                	je     f0106406 <readline+0xa6>
f0106401:	83 fb 0a             	cmp    $0xa,%ebx
f0106404:	75 8d                	jne    f0106393 <readline+0x33>
			if (echoing)
f0106406:	85 ff                	test   %edi,%edi
f0106408:	74 0c                	je     f0106416 <readline+0xb6>
				cputchar('\n');
f010640a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0106411:	e8 64 a3 ff ff       	call   f010077a <cputchar>
			buf[i] = 0;
f0106416:	c6 86 80 1a 23 f0 00 	movb   $0x0,-0xfdce580(%esi)
			return buf;
f010641d:	b8 80 1a 23 f0       	mov    $0xf0231a80,%eax
		}
	}
}
f0106422:	83 c4 1c             	add    $0x1c,%esp
f0106425:	5b                   	pop    %ebx
f0106426:	5e                   	pop    %esi
f0106427:	5f                   	pop    %edi
f0106428:	5d                   	pop    %ebp
f0106429:	c3                   	ret    
f010642a:	66 90                	xchg   %ax,%ax
f010642c:	66 90                	xchg   %ax,%ax
f010642e:	66 90                	xchg   %ax,%ax

f0106430 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0106430:	55                   	push   %ebp
f0106431:	89 e5                	mov    %esp,%ebp
f0106433:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106436:	b8 00 00 00 00       	mov    $0x0,%eax
f010643b:	eb 03                	jmp    f0106440 <strlen+0x10>
		n++;
f010643d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0106440:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0106444:	75 f7                	jne    f010643d <strlen+0xd>
	return n;
}
f0106446:	5d                   	pop    %ebp
f0106447:	c3                   	ret    

f0106448 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0106448:	55                   	push   %ebp
f0106449:	89 e5                	mov    %esp,%ebp
f010644b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010644e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106451:	b8 00 00 00 00       	mov    $0x0,%eax
f0106456:	eb 03                	jmp    f010645b <strnlen+0x13>
		n++;
f0106458:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010645b:	39 d0                	cmp    %edx,%eax
f010645d:	74 06                	je     f0106465 <strnlen+0x1d>
f010645f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0106463:	75 f3                	jne    f0106458 <strnlen+0x10>
	return n;
}
f0106465:	5d                   	pop    %ebp
f0106466:	c3                   	ret    

f0106467 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0106467:	55                   	push   %ebp
f0106468:	89 e5                	mov    %esp,%ebp
f010646a:	53                   	push   %ebx
f010646b:	8b 45 08             	mov    0x8(%ebp),%eax
f010646e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106471:	89 c2                	mov    %eax,%edx
f0106473:	83 c2 01             	add    $0x1,%edx
f0106476:	83 c1 01             	add    $0x1,%ecx
f0106479:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010647d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0106480:	84 db                	test   %bl,%bl
f0106482:	75 ef                	jne    f0106473 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0106484:	5b                   	pop    %ebx
f0106485:	5d                   	pop    %ebp
f0106486:	c3                   	ret    

f0106487 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0106487:	55                   	push   %ebp
f0106488:	89 e5                	mov    %esp,%ebp
f010648a:	53                   	push   %ebx
f010648b:	83 ec 08             	sub    $0x8,%esp
f010648e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106491:	89 1c 24             	mov    %ebx,(%esp)
f0106494:	e8 97 ff ff ff       	call   f0106430 <strlen>
	strcpy(dst + len, src);
f0106499:	8b 55 0c             	mov    0xc(%ebp),%edx
f010649c:	89 54 24 04          	mov    %edx,0x4(%esp)
f01064a0:	01 d8                	add    %ebx,%eax
f01064a2:	89 04 24             	mov    %eax,(%esp)
f01064a5:	e8 bd ff ff ff       	call   f0106467 <strcpy>
	return dst;
}
f01064aa:	89 d8                	mov    %ebx,%eax
f01064ac:	83 c4 08             	add    $0x8,%esp
f01064af:	5b                   	pop    %ebx
f01064b0:	5d                   	pop    %ebp
f01064b1:	c3                   	ret    

f01064b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01064b2:	55                   	push   %ebp
f01064b3:	89 e5                	mov    %esp,%ebp
f01064b5:	56                   	push   %esi
f01064b6:	53                   	push   %ebx
f01064b7:	8b 75 08             	mov    0x8(%ebp),%esi
f01064ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01064bd:	89 f3                	mov    %esi,%ebx
f01064bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01064c2:	89 f2                	mov    %esi,%edx
f01064c4:	eb 0f                	jmp    f01064d5 <strncpy+0x23>
		*dst++ = *src;
f01064c6:	83 c2 01             	add    $0x1,%edx
f01064c9:	0f b6 01             	movzbl (%ecx),%eax
f01064cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01064cf:	80 39 01             	cmpb   $0x1,(%ecx)
f01064d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f01064d5:	39 da                	cmp    %ebx,%edx
f01064d7:	75 ed                	jne    f01064c6 <strncpy+0x14>
	}
	return ret;
}
f01064d9:	89 f0                	mov    %esi,%eax
f01064db:	5b                   	pop    %ebx
f01064dc:	5e                   	pop    %esi
f01064dd:	5d                   	pop    %ebp
f01064de:	c3                   	ret    

f01064df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01064df:	55                   	push   %ebp
f01064e0:	89 e5                	mov    %esp,%ebp
f01064e2:	56                   	push   %esi
f01064e3:	53                   	push   %ebx
f01064e4:	8b 75 08             	mov    0x8(%ebp),%esi
f01064e7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01064ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01064ed:	89 f0                	mov    %esi,%eax
f01064ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01064f3:	85 c9                	test   %ecx,%ecx
f01064f5:	75 0b                	jne    f0106502 <strlcpy+0x23>
f01064f7:	eb 1d                	jmp    f0106516 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01064f9:	83 c0 01             	add    $0x1,%eax
f01064fc:	83 c2 01             	add    $0x1,%edx
f01064ff:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0106502:	39 d8                	cmp    %ebx,%eax
f0106504:	74 0b                	je     f0106511 <strlcpy+0x32>
f0106506:	0f b6 0a             	movzbl (%edx),%ecx
f0106509:	84 c9                	test   %cl,%cl
f010650b:	75 ec                	jne    f01064f9 <strlcpy+0x1a>
f010650d:	89 c2                	mov    %eax,%edx
f010650f:	eb 02                	jmp    f0106513 <strlcpy+0x34>
f0106511:	89 c2                	mov    %eax,%edx
		*dst = '\0';
f0106513:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0106516:	29 f0                	sub    %esi,%eax
}
f0106518:	5b                   	pop    %ebx
f0106519:	5e                   	pop    %esi
f010651a:	5d                   	pop    %ebp
f010651b:	c3                   	ret    

f010651c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010651c:	55                   	push   %ebp
f010651d:	89 e5                	mov    %esp,%ebp
f010651f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106522:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0106525:	eb 06                	jmp    f010652d <strcmp+0x11>
		p++, q++;
f0106527:	83 c1 01             	add    $0x1,%ecx
f010652a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010652d:	0f b6 01             	movzbl (%ecx),%eax
f0106530:	84 c0                	test   %al,%al
f0106532:	74 04                	je     f0106538 <strcmp+0x1c>
f0106534:	3a 02                	cmp    (%edx),%al
f0106536:	74 ef                	je     f0106527 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0106538:	0f b6 c0             	movzbl %al,%eax
f010653b:	0f b6 12             	movzbl (%edx),%edx
f010653e:	29 d0                	sub    %edx,%eax
}
f0106540:	5d                   	pop    %ebp
f0106541:	c3                   	ret    

f0106542 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106542:	55                   	push   %ebp
f0106543:	89 e5                	mov    %esp,%ebp
f0106545:	53                   	push   %ebx
f0106546:	8b 45 08             	mov    0x8(%ebp),%eax
f0106549:	8b 55 0c             	mov    0xc(%ebp),%edx
f010654c:	89 c3                	mov    %eax,%ebx
f010654e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0106551:	eb 06                	jmp    f0106559 <strncmp+0x17>
		n--, p++, q++;
f0106553:	83 c0 01             	add    $0x1,%eax
f0106556:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0106559:	39 d8                	cmp    %ebx,%eax
f010655b:	74 15                	je     f0106572 <strncmp+0x30>
f010655d:	0f b6 08             	movzbl (%eax),%ecx
f0106560:	84 c9                	test   %cl,%cl
f0106562:	74 04                	je     f0106568 <strncmp+0x26>
f0106564:	3a 0a                	cmp    (%edx),%cl
f0106566:	74 eb                	je     f0106553 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106568:	0f b6 00             	movzbl (%eax),%eax
f010656b:	0f b6 12             	movzbl (%edx),%edx
f010656e:	29 d0                	sub    %edx,%eax
f0106570:	eb 05                	jmp    f0106577 <strncmp+0x35>
		return 0;
f0106572:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106577:	5b                   	pop    %ebx
f0106578:	5d                   	pop    %ebp
f0106579:	c3                   	ret    

f010657a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010657a:	55                   	push   %ebp
f010657b:	89 e5                	mov    %esp,%ebp
f010657d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106580:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106584:	eb 07                	jmp    f010658d <strchr+0x13>
		if (*s == c)
f0106586:	38 ca                	cmp    %cl,%dl
f0106588:	74 0f                	je     f0106599 <strchr+0x1f>
	for (; *s; s++)
f010658a:	83 c0 01             	add    $0x1,%eax
f010658d:	0f b6 10             	movzbl (%eax),%edx
f0106590:	84 d2                	test   %dl,%dl
f0106592:	75 f2                	jne    f0106586 <strchr+0xc>
			return (char *) s;
	return 0;
f0106594:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106599:	5d                   	pop    %ebp
f010659a:	c3                   	ret    

f010659b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010659b:	55                   	push   %ebp
f010659c:	89 e5                	mov    %esp,%ebp
f010659e:	8b 45 08             	mov    0x8(%ebp),%eax
f01065a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01065a5:	eb 07                	jmp    f01065ae <strfind+0x13>
		if (*s == c)
f01065a7:	38 ca                	cmp    %cl,%dl
f01065a9:	74 0a                	je     f01065b5 <strfind+0x1a>
	for (; *s; s++)
f01065ab:	83 c0 01             	add    $0x1,%eax
f01065ae:	0f b6 10             	movzbl (%eax),%edx
f01065b1:	84 d2                	test   %dl,%dl
f01065b3:	75 f2                	jne    f01065a7 <strfind+0xc>
			break;
	return (char *) s;
}
f01065b5:	5d                   	pop    %ebp
f01065b6:	c3                   	ret    

f01065b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01065b7:	55                   	push   %ebp
f01065b8:	89 e5                	mov    %esp,%ebp
f01065ba:	57                   	push   %edi
f01065bb:	56                   	push   %esi
f01065bc:	53                   	push   %ebx
f01065bd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01065c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01065c3:	85 c9                	test   %ecx,%ecx
f01065c5:	74 36                	je     f01065fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01065c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01065cd:	75 28                	jne    f01065f7 <memset+0x40>
f01065cf:	f6 c1 03             	test   $0x3,%cl
f01065d2:	75 23                	jne    f01065f7 <memset+0x40>
		c &= 0xFF;
f01065d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01065d8:	89 d3                	mov    %edx,%ebx
f01065da:	c1 e3 08             	shl    $0x8,%ebx
f01065dd:	89 d6                	mov    %edx,%esi
f01065df:	c1 e6 18             	shl    $0x18,%esi
f01065e2:	89 d0                	mov    %edx,%eax
f01065e4:	c1 e0 10             	shl    $0x10,%eax
f01065e7:	09 f0                	or     %esi,%eax
f01065e9:	09 c2                	or     %eax,%edx
f01065eb:	89 d0                	mov    %edx,%eax
f01065ed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01065ef:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01065f2:	fc                   	cld    
f01065f3:	f3 ab                	rep stos %eax,%es:(%edi)
f01065f5:	eb 06                	jmp    f01065fd <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01065f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01065fa:	fc                   	cld    
f01065fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01065fd:	89 f8                	mov    %edi,%eax
f01065ff:	5b                   	pop    %ebx
f0106600:	5e                   	pop    %esi
f0106601:	5f                   	pop    %edi
f0106602:	5d                   	pop    %ebp
f0106603:	c3                   	ret    

f0106604 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106604:	55                   	push   %ebp
f0106605:	89 e5                	mov    %esp,%ebp
f0106607:	57                   	push   %edi
f0106608:	56                   	push   %esi
f0106609:	8b 45 08             	mov    0x8(%ebp),%eax
f010660c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010660f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106612:	39 c6                	cmp    %eax,%esi
f0106614:	73 35                	jae    f010664b <memmove+0x47>
f0106616:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106619:	39 d0                	cmp    %edx,%eax
f010661b:	73 2e                	jae    f010664b <memmove+0x47>
		s += n;
		d += n;
f010661d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0106620:	89 d6                	mov    %edx,%esi
f0106622:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106624:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010662a:	75 13                	jne    f010663f <memmove+0x3b>
f010662c:	f6 c1 03             	test   $0x3,%cl
f010662f:	75 0e                	jne    f010663f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106631:	83 ef 04             	sub    $0x4,%edi
f0106634:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106637:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010663a:	fd                   	std    
f010663b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010663d:	eb 09                	jmp    f0106648 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010663f:	83 ef 01             	sub    $0x1,%edi
f0106642:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0106645:	fd                   	std    
f0106646:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106648:	fc                   	cld    
f0106649:	eb 1d                	jmp    f0106668 <memmove+0x64>
f010664b:	89 f2                	mov    %esi,%edx
f010664d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010664f:	f6 c2 03             	test   $0x3,%dl
f0106652:	75 0f                	jne    f0106663 <memmove+0x5f>
f0106654:	f6 c1 03             	test   $0x3,%cl
f0106657:	75 0a                	jne    f0106663 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0106659:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010665c:	89 c7                	mov    %eax,%edi
f010665e:	fc                   	cld    
f010665f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106661:	eb 05                	jmp    f0106668 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
f0106663:	89 c7                	mov    %eax,%edi
f0106665:	fc                   	cld    
f0106666:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106668:	5e                   	pop    %esi
f0106669:	5f                   	pop    %edi
f010666a:	5d                   	pop    %ebp
f010666b:	c3                   	ret    

f010666c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010666c:	55                   	push   %ebp
f010666d:	89 e5                	mov    %esp,%ebp
f010666f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106672:	8b 45 10             	mov    0x10(%ebp),%eax
f0106675:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106679:	8b 45 0c             	mov    0xc(%ebp),%eax
f010667c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106680:	8b 45 08             	mov    0x8(%ebp),%eax
f0106683:	89 04 24             	mov    %eax,(%esp)
f0106686:	e8 79 ff ff ff       	call   f0106604 <memmove>
}
f010668b:	c9                   	leave  
f010668c:	c3                   	ret    

f010668d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010668d:	55                   	push   %ebp
f010668e:	89 e5                	mov    %esp,%ebp
f0106690:	56                   	push   %esi
f0106691:	53                   	push   %ebx
f0106692:	8b 55 08             	mov    0x8(%ebp),%edx
f0106695:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106698:	89 d6                	mov    %edx,%esi
f010669a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010669d:	eb 1a                	jmp    f01066b9 <memcmp+0x2c>
		if (*s1 != *s2)
f010669f:	0f b6 02             	movzbl (%edx),%eax
f01066a2:	0f b6 19             	movzbl (%ecx),%ebx
f01066a5:	38 d8                	cmp    %bl,%al
f01066a7:	74 0a                	je     f01066b3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01066a9:	0f b6 c0             	movzbl %al,%eax
f01066ac:	0f b6 db             	movzbl %bl,%ebx
f01066af:	29 d8                	sub    %ebx,%eax
f01066b1:	eb 0f                	jmp    f01066c2 <memcmp+0x35>
		s1++, s2++;
f01066b3:	83 c2 01             	add    $0x1,%edx
f01066b6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
f01066b9:	39 f2                	cmp    %esi,%edx
f01066bb:	75 e2                	jne    f010669f <memcmp+0x12>
	}

	return 0;
f01066bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01066c2:	5b                   	pop    %ebx
f01066c3:	5e                   	pop    %esi
f01066c4:	5d                   	pop    %ebp
f01066c5:	c3                   	ret    

f01066c6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01066c6:	55                   	push   %ebp
f01066c7:	89 e5                	mov    %esp,%ebp
f01066c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01066cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01066cf:	89 c2                	mov    %eax,%edx
f01066d1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01066d4:	eb 07                	jmp    f01066dd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01066d6:	38 08                	cmp    %cl,(%eax)
f01066d8:	74 07                	je     f01066e1 <memfind+0x1b>
	for (; s < ends; s++)
f01066da:	83 c0 01             	add    $0x1,%eax
f01066dd:	39 d0                	cmp    %edx,%eax
f01066df:	72 f5                	jb     f01066d6 <memfind+0x10>
			break;
	return (void *) s;
}
f01066e1:	5d                   	pop    %ebp
f01066e2:	c3                   	ret    

f01066e3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01066e3:	55                   	push   %ebp
f01066e4:	89 e5                	mov    %esp,%ebp
f01066e6:	57                   	push   %edi
f01066e7:	56                   	push   %esi
f01066e8:	53                   	push   %ebx
f01066e9:	8b 55 08             	mov    0x8(%ebp),%edx
f01066ec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01066ef:	eb 03                	jmp    f01066f4 <strtol+0x11>
		s++;
f01066f1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f01066f4:	0f b6 0a             	movzbl (%edx),%ecx
f01066f7:	80 f9 09             	cmp    $0x9,%cl
f01066fa:	74 f5                	je     f01066f1 <strtol+0xe>
f01066fc:	80 f9 20             	cmp    $0x20,%cl
f01066ff:	74 f0                	je     f01066f1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0106701:	80 f9 2b             	cmp    $0x2b,%cl
f0106704:	75 0a                	jne    f0106710 <strtol+0x2d>
		s++;
f0106706:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0106709:	bf 00 00 00 00       	mov    $0x0,%edi
f010670e:	eb 11                	jmp    f0106721 <strtol+0x3e>
f0106710:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f0106715:	80 f9 2d             	cmp    $0x2d,%cl
f0106718:	75 07                	jne    f0106721 <strtol+0x3e>
		s++, neg = 1;
f010671a:	8d 52 01             	lea    0x1(%edx),%edx
f010671d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106721:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0106726:	75 15                	jne    f010673d <strtol+0x5a>
f0106728:	80 3a 30             	cmpb   $0x30,(%edx)
f010672b:	75 10                	jne    f010673d <strtol+0x5a>
f010672d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106731:	75 0a                	jne    f010673d <strtol+0x5a>
		s += 2, base = 16;
f0106733:	83 c2 02             	add    $0x2,%edx
f0106736:	b8 10 00 00 00       	mov    $0x10,%eax
f010673b:	eb 10                	jmp    f010674d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010673d:	85 c0                	test   %eax,%eax
f010673f:	75 0c                	jne    f010674d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106741:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
f0106743:	80 3a 30             	cmpb   $0x30,(%edx)
f0106746:	75 05                	jne    f010674d <strtol+0x6a>
		s++, base = 8;
f0106748:	83 c2 01             	add    $0x1,%edx
f010674b:	b0 08                	mov    $0x8,%al
		base = 10;
f010674d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106752:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106755:	0f b6 0a             	movzbl (%edx),%ecx
f0106758:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010675b:	89 f0                	mov    %esi,%eax
f010675d:	3c 09                	cmp    $0x9,%al
f010675f:	77 08                	ja     f0106769 <strtol+0x86>
			dig = *s - '0';
f0106761:	0f be c9             	movsbl %cl,%ecx
f0106764:	83 e9 30             	sub    $0x30,%ecx
f0106767:	eb 20                	jmp    f0106789 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0106769:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010676c:	89 f0                	mov    %esi,%eax
f010676e:	3c 19                	cmp    $0x19,%al
f0106770:	77 08                	ja     f010677a <strtol+0x97>
			dig = *s - 'a' + 10;
f0106772:	0f be c9             	movsbl %cl,%ecx
f0106775:	83 e9 57             	sub    $0x57,%ecx
f0106778:	eb 0f                	jmp    f0106789 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010677a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010677d:	89 f0                	mov    %esi,%eax
f010677f:	3c 19                	cmp    $0x19,%al
f0106781:	77 16                	ja     f0106799 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0106783:	0f be c9             	movsbl %cl,%ecx
f0106786:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106789:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010678c:	7d 0f                	jge    f010679d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f010678e:	83 c2 01             	add    $0x1,%edx
f0106791:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0106795:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0106797:	eb bc                	jmp    f0106755 <strtol+0x72>
f0106799:	89 d8                	mov    %ebx,%eax
f010679b:	eb 02                	jmp    f010679f <strtol+0xbc>
f010679d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f010679f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01067a3:	74 05                	je     f01067aa <strtol+0xc7>
		*endptr = (char *) s;
f01067a5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01067a8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01067aa:	f7 d8                	neg    %eax
f01067ac:	85 ff                	test   %edi,%edi
f01067ae:	0f 44 c3             	cmove  %ebx,%eax
}
f01067b1:	5b                   	pop    %ebx
f01067b2:	5e                   	pop    %esi
f01067b3:	5f                   	pop    %edi
f01067b4:	5d                   	pop    %ebp
f01067b5:	c3                   	ret    
f01067b6:	66 90                	xchg   %ax,%ax

f01067b8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01067b8:	fa                   	cli    

	xorw    %ax, %ax
f01067b9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01067bb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01067bd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01067bf:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01067c1:	0f 01 16             	lgdtl  (%esi)
f01067c4:	74 70                	je     f0106836 <mpentry_end+0x4>
	movl    %cr0, %eax
f01067c6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01067c9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01067cd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01067d0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01067d6:	08 00                	or     %al,(%eax)

f01067d8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01067d8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01067dc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01067de:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01067e0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01067e2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01067e6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01067e8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01067ea:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f01067ef:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01067f2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01067f5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01067fa:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01067fd:	8b 25 84 1e 23 f0    	mov    0xf0231e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106803:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106808:	b8 c2 01 10 f0       	mov    $0xf01001c2,%eax
	call    *%eax
f010680d:	ff d0                	call   *%eax

f010680f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010680f:	eb fe                	jmp    f010680f <spin>
f0106811:	8d 76 00             	lea    0x0(%esi),%esi

f0106814 <gdt>:
	...
f010681c:	ff                   	(bad)  
f010681d:	ff 00                	incl   (%eax)
f010681f:	00 00                	add    %al,(%eax)
f0106821:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106828:	00                   	.byte 0x0
f0106829:	92                   	xchg   %eax,%edx
f010682a:	cf                   	iret   
	...

f010682c <gdtdesc>:
f010682c:	17                   	pop    %ss
f010682d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106832 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106832:	90                   	nop
f0106833:	66 90                	xchg   %ax,%ax
f0106835:	66 90                	xchg   %ax,%ax
f0106837:	66 90                	xchg   %ax,%ax
f0106839:	66 90                	xchg   %ax,%ax
f010683b:	66 90                	xchg   %ax,%ax
f010683d:	66 90                	xchg   %ax,%ax
f010683f:	90                   	nop

f0106840 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106840:	55                   	push   %ebp
f0106841:	89 e5                	mov    %esp,%ebp
f0106843:	56                   	push   %esi
f0106844:	53                   	push   %ebx
f0106845:	83 ec 10             	sub    $0x10,%esp
	if (PGNUM(pa) >= npages)
f0106848:	8b 0d 88 1e 23 f0    	mov    0xf0231e88,%ecx
f010684e:	89 c3                	mov    %eax,%ebx
f0106850:	c1 eb 0c             	shr    $0xc,%ebx
f0106853:	39 cb                	cmp    %ecx,%ebx
f0106855:	72 20                	jb     f0106877 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106857:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010685b:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0106862:	f0 
f0106863:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010686a:	00 
f010686b:	c7 04 24 21 92 10 f0 	movl   $0xf0109221,(%esp)
f0106872:	e8 c9 97 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106877:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010687d:	01 d0                	add    %edx,%eax
	if (PGNUM(pa) >= npages)
f010687f:	89 c2                	mov    %eax,%edx
f0106881:	c1 ea 0c             	shr    $0xc,%edx
f0106884:	39 d1                	cmp    %edx,%ecx
f0106886:	77 20                	ja     f01068a8 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106888:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010688c:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0106893:	f0 
f0106894:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010689b:	00 
f010689c:	c7 04 24 21 92 10 f0 	movl   $0xf0109221,(%esp)
f01068a3:	e8 98 97 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01068a8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01068ae:	eb 36                	jmp    f01068e6 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01068b0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01068b7:	00 
f01068b8:	c7 44 24 04 31 92 10 	movl   $0xf0109231,0x4(%esp)
f01068bf:	f0 
f01068c0:	89 1c 24             	mov    %ebx,(%esp)
f01068c3:	e8 c5 fd ff ff       	call   f010668d <memcmp>
f01068c8:	85 c0                	test   %eax,%eax
f01068ca:	75 17                	jne    f01068e3 <mpsearch1+0xa3>
	for (i = 0; i < len; i++)
f01068cc:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f01068d1:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01068d5:	01 c8                	add    %ecx,%eax
	for (i = 0; i < len; i++)
f01068d7:	83 c2 01             	add    $0x1,%edx
f01068da:	83 fa 10             	cmp    $0x10,%edx
f01068dd:	75 f2                	jne    f01068d1 <mpsearch1+0x91>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01068df:	84 c0                	test   %al,%al
f01068e1:	74 0e                	je     f01068f1 <mpsearch1+0xb1>
	for (; mp < end; mp++)
f01068e3:	83 c3 10             	add    $0x10,%ebx
f01068e6:	39 f3                	cmp    %esi,%ebx
f01068e8:	72 c6                	jb     f01068b0 <mpsearch1+0x70>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01068ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01068ef:	eb 02                	jmp    f01068f3 <mpsearch1+0xb3>
f01068f1:	89 d8                	mov    %ebx,%eax
}
f01068f3:	83 c4 10             	add    $0x10,%esp
f01068f6:	5b                   	pop    %ebx
f01068f7:	5e                   	pop    %esi
f01068f8:	5d                   	pop    %ebp
f01068f9:	c3                   	ret    

f01068fa <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01068fa:	55                   	push   %ebp
f01068fb:	89 e5                	mov    %esp,%ebp
f01068fd:	57                   	push   %edi
f01068fe:	56                   	push   %esi
f01068ff:	53                   	push   %ebx
f0106900:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106903:	c7 05 c0 23 23 f0 20 	movl   $0xf0232020,0xf02323c0
f010690a:	20 23 f0 
	if (PGNUM(pa) >= npages)
f010690d:	83 3d 88 1e 23 f0 00 	cmpl   $0x0,0xf0231e88
f0106914:	75 24                	jne    f010693a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106916:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010691d:	00 
f010691e:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0106925:	f0 
f0106926:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010692d:	00 
f010692e:	c7 04 24 21 92 10 f0 	movl   $0xf0109221,(%esp)
f0106935:	e8 06 97 ff ff       	call   f0100040 <_panic>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010693a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106941:	85 c0                	test   %eax,%eax
f0106943:	74 16                	je     f010695b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106945:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106948:	ba 00 04 00 00       	mov    $0x400,%edx
f010694d:	e8 ee fe ff ff       	call   f0106840 <mpsearch1>
f0106952:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106955:	85 c0                	test   %eax,%eax
f0106957:	75 3c                	jne    f0106995 <mp_init+0x9b>
f0106959:	eb 20                	jmp    f010697b <mp_init+0x81>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010695b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106962:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106965:	2d 00 04 00 00       	sub    $0x400,%eax
f010696a:	ba 00 04 00 00       	mov    $0x400,%edx
f010696f:	e8 cc fe ff ff       	call   f0106840 <mpsearch1>
f0106974:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106977:	85 c0                	test   %eax,%eax
f0106979:	75 1a                	jne    f0106995 <mp_init+0x9b>
	return mpsearch1(0xF0000, 0x10000);
f010697b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106980:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106985:	e8 b6 fe ff ff       	call   f0106840 <mpsearch1>
f010698a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f010698d:	85 c0                	test   %eax,%eax
f010698f:	0f 84 54 02 00 00    	je     f0106be9 <mp_init+0x2ef>
	if (mp->physaddr == 0 || mp->type != 0) {
f0106995:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106998:	8b 70 04             	mov    0x4(%eax),%esi
f010699b:	85 f6                	test   %esi,%esi
f010699d:	74 06                	je     f01069a5 <mp_init+0xab>
f010699f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01069a3:	74 11                	je     f01069b6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01069a5:	c7 04 24 94 90 10 f0 	movl   $0xf0109094,(%esp)
f01069ac:	e8 9f d9 ff ff       	call   f0104350 <cprintf>
f01069b1:	e9 33 02 00 00       	jmp    f0106be9 <mp_init+0x2ef>
	if (PGNUM(pa) >= npages)
f01069b6:	89 f0                	mov    %esi,%eax
f01069b8:	c1 e8 0c             	shr    $0xc,%eax
f01069bb:	3b 05 88 1e 23 f0    	cmp    0xf0231e88,%eax
f01069c1:	72 20                	jb     f01069e3 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01069c3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01069c7:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f01069ce:	f0 
f01069cf:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01069d6:	00 
f01069d7:	c7 04 24 21 92 10 f0 	movl   $0xf0109221,(%esp)
f01069de:	e8 5d 96 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01069e3:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f01069e9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01069f0:	00 
f01069f1:	c7 44 24 04 36 92 10 	movl   $0xf0109236,0x4(%esp)
f01069f8:	f0 
f01069f9:	89 1c 24             	mov    %ebx,(%esp)
f01069fc:	e8 8c fc ff ff       	call   f010668d <memcmp>
f0106a01:	85 c0                	test   %eax,%eax
f0106a03:	74 11                	je     f0106a16 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106a05:	c7 04 24 c4 90 10 f0 	movl   $0xf01090c4,(%esp)
f0106a0c:	e8 3f d9 ff ff       	call   f0104350 <cprintf>
f0106a11:	e9 d3 01 00 00       	jmp    f0106be9 <mp_init+0x2ef>
	if (sum(conf, conf->length) != 0) {
f0106a16:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0106a1a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0106a1e:	0f b7 f8             	movzwl %ax,%edi
	sum = 0;
f0106a21:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106a26:	b8 00 00 00 00       	mov    $0x0,%eax
f0106a2b:	eb 0d                	jmp    f0106a3a <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f0106a2d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106a34:	f0 
f0106a35:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106a37:	83 c0 01             	add    $0x1,%eax
f0106a3a:	39 c7                	cmp    %eax,%edi
f0106a3c:	7f ef                	jg     f0106a2d <mp_init+0x133>
	if (sum(conf, conf->length) != 0) {
f0106a3e:	84 d2                	test   %dl,%dl
f0106a40:	74 11                	je     f0106a53 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106a42:	c7 04 24 f8 90 10 f0 	movl   $0xf01090f8,(%esp)
f0106a49:	e8 02 d9 ff ff       	call   f0104350 <cprintf>
f0106a4e:	e9 96 01 00 00       	jmp    f0106be9 <mp_init+0x2ef>
	if (conf->version != 1 && conf->version != 4) {
f0106a53:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106a57:	3c 04                	cmp    $0x4,%al
f0106a59:	74 1f                	je     f0106a7a <mp_init+0x180>
f0106a5b:	3c 01                	cmp    $0x1,%al
f0106a5d:	8d 76 00             	lea    0x0(%esi),%esi
f0106a60:	74 18                	je     f0106a7a <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106a62:	0f b6 c0             	movzbl %al,%eax
f0106a65:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a69:	c7 04 24 1c 91 10 f0 	movl   $0xf010911c,(%esp)
f0106a70:	e8 db d8 ff ff       	call   f0104350 <cprintf>
f0106a75:	e9 6f 01 00 00       	jmp    f0106be9 <mp_init+0x2ef>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106a7a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f0106a7e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f0106a82:	01 df                	add    %ebx,%edi
	sum = 0;
f0106a84:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106a89:	b8 00 00 00 00       	mov    $0x0,%eax
f0106a8e:	eb 09                	jmp    f0106a99 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f0106a90:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f0106a94:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106a96:	83 c0 01             	add    $0x1,%eax
f0106a99:	39 c6                	cmp    %eax,%esi
f0106a9b:	7f f3                	jg     f0106a90 <mp_init+0x196>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106a9d:	02 53 2a             	add    0x2a(%ebx),%dl
f0106aa0:	84 d2                	test   %dl,%dl
f0106aa2:	74 11                	je     f0106ab5 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106aa4:	c7 04 24 3c 91 10 f0 	movl   $0xf010913c,(%esp)
f0106aab:	e8 a0 d8 ff ff       	call   f0104350 <cprintf>
f0106ab0:	e9 34 01 00 00       	jmp    f0106be9 <mp_init+0x2ef>
	if ((conf = mpconfig(&mp)) == 0)
f0106ab5:	85 db                	test   %ebx,%ebx
f0106ab7:	0f 84 2c 01 00 00    	je     f0106be9 <mp_init+0x2ef>
		return;
	ismp = 1;
f0106abd:	c7 05 00 20 23 f0 01 	movl   $0x1,0xf0232000
f0106ac4:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106ac7:	8b 43 24             	mov    0x24(%ebx),%eax
f0106aca:	a3 00 30 27 f0       	mov    %eax,0xf0273000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106acf:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106ad2:	be 00 00 00 00       	mov    $0x0,%esi
f0106ad7:	e9 86 00 00 00       	jmp    f0106b62 <mp_init+0x268>
		switch (*p) {
f0106adc:	0f b6 07             	movzbl (%edi),%eax
f0106adf:	84 c0                	test   %al,%al
f0106ae1:	74 06                	je     f0106ae9 <mp_init+0x1ef>
f0106ae3:	3c 04                	cmp    $0x4,%al
f0106ae5:	77 57                	ja     f0106b3e <mp_init+0x244>
f0106ae7:	eb 50                	jmp    f0106b39 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106ae9:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0106aed:	8d 76 00             	lea    0x0(%esi),%esi
f0106af0:	74 11                	je     f0106b03 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106af2:	6b 05 c4 23 23 f0 74 	imul   $0x74,0xf02323c4,%eax
f0106af9:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0106afe:	a3 c0 23 23 f0       	mov    %eax,0xf02323c0
			if (ncpu < NCPU) {
f0106b03:	a1 c4 23 23 f0       	mov    0xf02323c4,%eax
f0106b08:	83 f8 07             	cmp    $0x7,%eax
f0106b0b:	7f 13                	jg     f0106b20 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f0106b0d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106b10:	88 82 20 20 23 f0    	mov    %al,-0xfdcdfe0(%edx)
				ncpu++;
f0106b16:	83 c0 01             	add    $0x1,%eax
f0106b19:	a3 c4 23 23 f0       	mov    %eax,0xf02323c4
f0106b1e:	eb 14                	jmp    f0106b34 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106b20:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106b24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b28:	c7 04 24 6c 91 10 f0 	movl   $0xf010916c,(%esp)
f0106b2f:	e8 1c d8 ff ff       	call   f0104350 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106b34:	83 c7 14             	add    $0x14,%edi
			continue;
f0106b37:	eb 26                	jmp    f0106b5f <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106b39:	83 c7 08             	add    $0x8,%edi
			continue;
f0106b3c:	eb 21                	jmp    f0106b5f <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106b3e:	0f b6 c0             	movzbl %al,%eax
f0106b41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b45:	c7 04 24 94 91 10 f0 	movl   $0xf0109194,(%esp)
f0106b4c:	e8 ff d7 ff ff       	call   f0104350 <cprintf>
			ismp = 0;
f0106b51:	c7 05 00 20 23 f0 00 	movl   $0x0,0xf0232000
f0106b58:	00 00 00 
			i = conf->entry;
f0106b5b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106b5f:	83 c6 01             	add    $0x1,%esi
f0106b62:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106b66:	39 c6                	cmp    %eax,%esi
f0106b68:	0f 82 6e ff ff ff    	jb     f0106adc <mp_init+0x1e2>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106b6e:	a1 c0 23 23 f0       	mov    0xf02323c0,%eax
f0106b73:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106b7a:	83 3d 00 20 23 f0 00 	cmpl   $0x0,0xf0232000
f0106b81:	75 22                	jne    f0106ba5 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106b83:	c7 05 c4 23 23 f0 01 	movl   $0x1,0xf02323c4
f0106b8a:	00 00 00 
		lapicaddr = 0;
f0106b8d:	c7 05 00 30 27 f0 00 	movl   $0x0,0xf0273000
f0106b94:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106b97:	c7 04 24 b4 91 10 f0 	movl   $0xf01091b4,(%esp)
f0106b9e:	e8 ad d7 ff ff       	call   f0104350 <cprintf>
		return;
f0106ba3:	eb 44                	jmp    f0106be9 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106ba5:	8b 15 c4 23 23 f0    	mov    0xf02323c4,%edx
f0106bab:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106baf:	0f b6 00             	movzbl (%eax),%eax
f0106bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106bb6:	c7 04 24 3b 92 10 f0 	movl   $0xf010923b,(%esp)
f0106bbd:	e8 8e d7 ff ff       	call   f0104350 <cprintf>

	if (mp->imcrp) {
f0106bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106bc5:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106bc9:	74 1e                	je     f0106be9 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106bcb:	c7 04 24 e0 91 10 f0 	movl   $0xf01091e0,(%esp)
f0106bd2:	e8 79 d7 ff ff       	call   f0104350 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106bd7:	ba 22 00 00 00       	mov    $0x22,%edx
f0106bdc:	b8 70 00 00 00       	mov    $0x70,%eax
f0106be1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106be2:	b2 23                	mov    $0x23,%dl
f0106be4:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106be5:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106be8:	ee                   	out    %al,(%dx)
	}
}
f0106be9:	83 c4 2c             	add    $0x2c,%esp
f0106bec:	5b                   	pop    %ebx
f0106bed:	5e                   	pop    %esi
f0106bee:	5f                   	pop    %edi
f0106bef:	5d                   	pop    %ebp
f0106bf0:	c3                   	ret    

f0106bf1 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106bf1:	55                   	push   %ebp
f0106bf2:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106bf4:	8b 0d 04 30 27 f0    	mov    0xf0273004,%ecx
f0106bfa:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106bfd:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106bff:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0106c04:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106c07:	5d                   	pop    %ebp
f0106c08:	c3                   	ret    

f0106c09 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106c09:	55                   	push   %ebp
f0106c0a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106c0c:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0106c11:	85 c0                	test   %eax,%eax
f0106c13:	74 08                	je     f0106c1d <cpunum+0x14>
		return lapic[ID] >> 24;
f0106c15:	8b 40 20             	mov    0x20(%eax),%eax
f0106c18:	c1 e8 18             	shr    $0x18,%eax
f0106c1b:	eb 05                	jmp    f0106c22 <cpunum+0x19>
	return 0;
f0106c1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106c22:	5d                   	pop    %ebp
f0106c23:	c3                   	ret    

f0106c24 <lapic_init>:
	if (!lapicaddr)
f0106c24:	a1 00 30 27 f0       	mov    0xf0273000,%eax
f0106c29:	85 c0                	test   %eax,%eax
f0106c2b:	0f 84 23 01 00 00    	je     f0106d54 <lapic_init+0x130>
{
f0106c31:	55                   	push   %ebp
f0106c32:	89 e5                	mov    %esp,%ebp
f0106c34:	83 ec 18             	sub    $0x18,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106c37:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106c3e:	00 
f0106c3f:	89 04 24             	mov    %eax,(%esp)
f0106c42:	e8 23 ac ff ff       	call   f010186a <mmio_map_region>
f0106c47:	a3 04 30 27 f0       	mov    %eax,0xf0273004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106c4c:	ba 27 01 00 00       	mov    $0x127,%edx
f0106c51:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106c56:	e8 96 ff ff ff       	call   f0106bf1 <lapicw>
	lapicw(TDCR, X1);
f0106c5b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106c60:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106c65:	e8 87 ff ff ff       	call   f0106bf1 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106c6a:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106c6f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106c74:	e8 78 ff ff ff       	call   f0106bf1 <lapicw>
	lapicw(TICR, 10000000); 
f0106c79:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106c7e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106c83:	e8 69 ff ff ff       	call   f0106bf1 <lapicw>
	if (thiscpu != bootcpu)
f0106c88:	e8 7c ff ff ff       	call   f0106c09 <cpunum>
f0106c8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106c90:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0106c95:	39 05 c0 23 23 f0    	cmp    %eax,0xf02323c0
f0106c9b:	74 0f                	je     f0106cac <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106c9d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106ca2:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106ca7:	e8 45 ff ff ff       	call   f0106bf1 <lapicw>
	lapicw(LINT1, MASKED);
f0106cac:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106cb1:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106cb6:	e8 36 ff ff ff       	call   f0106bf1 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106cbb:	a1 04 30 27 f0       	mov    0xf0273004,%eax
f0106cc0:	8b 40 30             	mov    0x30(%eax),%eax
f0106cc3:	c1 e8 10             	shr    $0x10,%eax
f0106cc6:	3c 03                	cmp    $0x3,%al
f0106cc8:	76 0f                	jbe    f0106cd9 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f0106cca:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106ccf:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106cd4:	e8 18 ff ff ff       	call   f0106bf1 <lapicw>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106cd9:	ba 33 00 00 00       	mov    $0x33,%edx
f0106cde:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106ce3:	e8 09 ff ff ff       	call   f0106bf1 <lapicw>
	lapicw(ESR, 0);
f0106ce8:	ba 00 00 00 00       	mov    $0x0,%edx
f0106ced:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106cf2:	e8 fa fe ff ff       	call   f0106bf1 <lapicw>
	lapicw(ESR, 0);
f0106cf7:	ba 00 00 00 00       	mov    $0x0,%edx
f0106cfc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106d01:	e8 eb fe ff ff       	call   f0106bf1 <lapicw>
	lapicw(EOI, 0);
f0106d06:	ba 00 00 00 00       	mov    $0x0,%edx
f0106d0b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106d10:	e8 dc fe ff ff       	call   f0106bf1 <lapicw>
	lapicw(ICRHI, 0);
f0106d15:	ba 00 00 00 00       	mov    $0x0,%edx
f0106d1a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d1f:	e8 cd fe ff ff       	call   f0106bf1 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106d24:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106d29:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d2e:	e8 be fe ff ff       	call   f0106bf1 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106d33:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f0106d39:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106d3f:	f6 c4 10             	test   $0x10,%ah
f0106d42:	75 f5                	jne    f0106d39 <lapic_init+0x115>
	lapicw(TPR, 0);
f0106d44:	ba 00 00 00 00       	mov    $0x0,%edx
f0106d49:	b8 20 00 00 00       	mov    $0x20,%eax
f0106d4e:	e8 9e fe ff ff       	call   f0106bf1 <lapicw>
}
f0106d53:	c9                   	leave  
f0106d54:	f3 c3                	repz ret 

f0106d56 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106d56:	83 3d 04 30 27 f0 00 	cmpl   $0x0,0xf0273004
f0106d5d:	74 13                	je     f0106d72 <lapic_eoi+0x1c>
{
f0106d5f:	55                   	push   %ebp
f0106d60:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0106d62:	ba 00 00 00 00       	mov    $0x0,%edx
f0106d67:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106d6c:	e8 80 fe ff ff       	call   f0106bf1 <lapicw>
}
f0106d71:	5d                   	pop    %ebp
f0106d72:	f3 c3                	repz ret 

f0106d74 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106d74:	55                   	push   %ebp
f0106d75:	89 e5                	mov    %esp,%ebp
f0106d77:	56                   	push   %esi
f0106d78:	53                   	push   %ebx
f0106d79:	83 ec 10             	sub    $0x10,%esp
f0106d7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106d7f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106d82:	ba 70 00 00 00       	mov    $0x70,%edx
f0106d87:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106d8c:	ee                   	out    %al,(%dx)
f0106d8d:	b2 71                	mov    $0x71,%dl
f0106d8f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106d94:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0106d95:	83 3d 88 1e 23 f0 00 	cmpl   $0x0,0xf0231e88
f0106d9c:	75 24                	jne    f0106dc2 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106d9e:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106da5:	00 
f0106da6:	c7 44 24 08 04 73 10 	movl   $0xf0107304,0x8(%esp)
f0106dad:	f0 
f0106dae:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106db5:	00 
f0106db6:	c7 04 24 58 92 10 f0 	movl   $0xf0109258,(%esp)
f0106dbd:	e8 7e 92 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106dc2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106dc9:	00 00 
	wrv[1] = addr >> 4;
f0106dcb:	89 f0                	mov    %esi,%eax
f0106dcd:	c1 e8 04             	shr    $0x4,%eax
f0106dd0:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106dd6:	c1 e3 18             	shl    $0x18,%ebx
f0106dd9:	89 da                	mov    %ebx,%edx
f0106ddb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106de0:	e8 0c fe ff ff       	call   f0106bf1 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106de5:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106dea:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106def:	e8 fd fd ff ff       	call   f0106bf1 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106df4:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106df9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106dfe:	e8 ee fd ff ff       	call   f0106bf1 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106e03:	c1 ee 0c             	shr    $0xc,%esi
f0106e06:	81 ce 00 06 00 00    	or     $0x600,%esi
		lapicw(ICRHI, apicid << 24);
f0106e0c:	89 da                	mov    %ebx,%edx
f0106e0e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106e13:	e8 d9 fd ff ff       	call   f0106bf1 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106e18:	89 f2                	mov    %esi,%edx
f0106e1a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106e1f:	e8 cd fd ff ff       	call   f0106bf1 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0106e24:	89 da                	mov    %ebx,%edx
f0106e26:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106e2b:	e8 c1 fd ff ff       	call   f0106bf1 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106e30:	89 f2                	mov    %esi,%edx
f0106e32:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106e37:	e8 b5 fd ff ff       	call   f0106bf1 <lapicw>
		microdelay(200);
	}
}
f0106e3c:	83 c4 10             	add    $0x10,%esp
f0106e3f:	5b                   	pop    %ebx
f0106e40:	5e                   	pop    %esi
f0106e41:	5d                   	pop    %ebp
f0106e42:	c3                   	ret    

f0106e43 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106e43:	55                   	push   %ebp
f0106e44:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106e46:	8b 55 08             	mov    0x8(%ebp),%edx
f0106e49:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106e4f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106e54:	e8 98 fd ff ff       	call   f0106bf1 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106e59:	8b 15 04 30 27 f0    	mov    0xf0273004,%edx
f0106e5f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106e65:	f6 c4 10             	test   $0x10,%ah
f0106e68:	75 f5                	jne    f0106e5f <lapic_ipi+0x1c>
		;
}
f0106e6a:	5d                   	pop    %ebp
f0106e6b:	c3                   	ret    

f0106e6c <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106e6c:	55                   	push   %ebp
f0106e6d:	89 e5                	mov    %esp,%ebp
f0106e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106e72:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106e78:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106e7b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106e7e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106e85:	5d                   	pop    %ebp
f0106e86:	c3                   	ret    

f0106e87 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106e87:	55                   	push   %ebp
f0106e88:	89 e5                	mov    %esp,%ebp
f0106e8a:	56                   	push   %esi
f0106e8b:	53                   	push   %ebx
f0106e8c:	83 ec 20             	sub    $0x20,%esp
f0106e8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106e92:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106e95:	75 07                	jne    f0106e9e <spin_lock+0x17>
	asm volatile("lock; xchgl %0, %1"
f0106e97:	ba 01 00 00 00       	mov    $0x1,%edx
f0106e9c:	eb 42                	jmp    f0106ee0 <spin_lock+0x59>
f0106e9e:	8b 73 08             	mov    0x8(%ebx),%esi
f0106ea1:	e8 63 fd ff ff       	call   f0106c09 <cpunum>
f0106ea6:	6b c0 74             	imul   $0x74,%eax,%eax
f0106ea9:	05 20 20 23 f0       	add    $0xf0232020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106eae:	39 c6                	cmp    %eax,%esi
f0106eb0:	75 e5                	jne    f0106e97 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106eb2:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106eb5:	e8 4f fd ff ff       	call   f0106c09 <cpunum>
f0106eba:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106ebe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106ec2:	c7 44 24 08 68 92 10 	movl   $0xf0109268,0x8(%esp)
f0106ec9:	f0 
f0106eca:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106ed1:	00 
f0106ed2:	c7 04 24 cc 92 10 f0 	movl   $0xf01092cc,(%esp)
f0106ed9:	e8 62 91 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106ede:	f3 90                	pause  
f0106ee0:	89 d0                	mov    %edx,%eax
f0106ee2:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106ee5:	85 c0                	test   %eax,%eax
f0106ee7:	75 f5                	jne    f0106ede <spin_lock+0x57>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106ee9:	e8 1b fd ff ff       	call   f0106c09 <cpunum>
f0106eee:	6b c0 74             	imul   $0x74,%eax,%eax
f0106ef1:	05 20 20 23 f0       	add    $0xf0232020,%eax
f0106ef6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106ef9:	83 c3 0c             	add    $0xc,%ebx
	ebp = (uint32_t *)read_ebp();
f0106efc:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106efe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106f03:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106f09:	76 12                	jbe    f0106f1d <spin_lock+0x96>
		pcs[i] = ebp[1];          // saved %eip
f0106f0b:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106f0e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106f11:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106f13:	83 c0 01             	add    $0x1,%eax
f0106f16:	83 f8 0a             	cmp    $0xa,%eax
f0106f19:	75 e8                	jne    f0106f03 <spin_lock+0x7c>
f0106f1b:	eb 0f                	jmp    f0106f2c <spin_lock+0xa5>
		pcs[i] = 0;
f0106f1d:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0106f24:	83 c0 01             	add    $0x1,%eax
f0106f27:	83 f8 09             	cmp    $0x9,%eax
f0106f2a:	7e f1                	jle    f0106f1d <spin_lock+0x96>
#endif
}
f0106f2c:	83 c4 20             	add    $0x20,%esp
f0106f2f:	5b                   	pop    %ebx
f0106f30:	5e                   	pop    %esi
f0106f31:	5d                   	pop    %ebp
f0106f32:	c3                   	ret    

f0106f33 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106f33:	55                   	push   %ebp
f0106f34:	89 e5                	mov    %esp,%ebp
f0106f36:	57                   	push   %edi
f0106f37:	56                   	push   %esi
f0106f38:	53                   	push   %ebx
f0106f39:	83 ec 6c             	sub    $0x6c,%esp
f0106f3c:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106f3f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106f42:	74 18                	je     f0106f5c <spin_unlock+0x29>
f0106f44:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106f47:	e8 bd fc ff ff       	call   f0106c09 <cpunum>
f0106f4c:	6b c0 74             	imul   $0x74,%eax,%eax
f0106f4f:	05 20 20 23 f0       	add    $0xf0232020,%eax
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106f54:	39 c3                	cmp    %eax,%ebx
f0106f56:	0f 84 ce 00 00 00    	je     f010702a <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106f5c:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106f63:	00 
f0106f64:	8d 46 0c             	lea    0xc(%esi),%eax
f0106f67:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f6b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106f6e:	89 1c 24             	mov    %ebx,(%esp)
f0106f71:	e8 8e f6 ff ff       	call   f0106604 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106f76:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106f79:	0f b6 38             	movzbl (%eax),%edi
f0106f7c:	8b 76 04             	mov    0x4(%esi),%esi
f0106f7f:	e8 85 fc ff ff       	call   f0106c09 <cpunum>
f0106f84:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106f88:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f90:	c7 04 24 94 92 10 f0 	movl   $0xf0109294,(%esp)
f0106f97:	e8 b4 d3 ff ff       	call   f0104350 <cprintf>
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106f9c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106f9f:	eb 65                	jmp    f0107006 <spin_unlock+0xd3>
f0106fa1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106fa5:	89 04 24             	mov    %eax,(%esp)
f0106fa8:	e8 cb ea ff ff       	call   f0105a78 <debuginfo_eip>
f0106fad:	85 c0                	test   %eax,%eax
f0106faf:	78 39                	js     f0106fea <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106fb1:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106fb3:	89 c2                	mov    %eax,%edx
f0106fb5:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106fb8:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106fbc:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106fbf:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106fc3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106fc6:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106fca:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0106fcd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106fd1:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106fd4:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106fdc:	c7 04 24 dc 92 10 f0 	movl   $0xf01092dc,(%esp)
f0106fe3:	e8 68 d3 ff ff       	call   f0104350 <cprintf>
f0106fe8:	eb 12                	jmp    f0106ffc <spin_unlock+0xc9>
			else
				cprintf("  %08x\n", pcs[i]);
f0106fea:	8b 06                	mov    (%esi),%eax
f0106fec:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ff0:	c7 04 24 f3 92 10 f0 	movl   $0xf01092f3,(%esp)
f0106ff7:	e8 54 d3 ff ff       	call   f0104350 <cprintf>
f0106ffc:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106fff:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0107002:	39 c3                	cmp    %eax,%ebx
f0107004:	74 08                	je     f010700e <spin_unlock+0xdb>
f0107006:	89 de                	mov    %ebx,%esi
f0107008:	8b 03                	mov    (%ebx),%eax
f010700a:	85 c0                	test   %eax,%eax
f010700c:	75 93                	jne    f0106fa1 <spin_unlock+0x6e>
		}
		panic("spin_unlock");
f010700e:	c7 44 24 08 fb 92 10 	movl   $0xf01092fb,0x8(%esp)
f0107015:	f0 
f0107016:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010701d:	00 
f010701e:	c7 04 24 cc 92 10 f0 	movl   $0xf01092cc,(%esp)
f0107025:	e8 16 90 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010702a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0107031:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0107038:	b8 00 00 00 00       	mov    $0x0,%eax
f010703d:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0107040:	83 c4 6c             	add    $0x6c,%esp
f0107043:	5b                   	pop    %ebx
f0107044:	5e                   	pop    %esi
f0107045:	5f                   	pop    %edi
f0107046:	5d                   	pop    %ebp
f0107047:	c3                   	ret    
f0107048:	66 90                	xchg   %ax,%ax
f010704a:	66 90                	xchg   %ax,%ax
f010704c:	66 90                	xchg   %ax,%ax
f010704e:	66 90                	xchg   %ax,%ax

f0107050 <__udivdi3>:
f0107050:	55                   	push   %ebp
f0107051:	57                   	push   %edi
f0107052:	56                   	push   %esi
f0107053:	83 ec 0c             	sub    $0xc,%esp
f0107056:	8b 44 24 28          	mov    0x28(%esp),%eax
f010705a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010705e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0107062:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0107066:	85 c0                	test   %eax,%eax
f0107068:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010706c:	89 ea                	mov    %ebp,%edx
f010706e:	89 0c 24             	mov    %ecx,(%esp)
f0107071:	75 2d                	jne    f01070a0 <__udivdi3+0x50>
f0107073:	39 e9                	cmp    %ebp,%ecx
f0107075:	77 61                	ja     f01070d8 <__udivdi3+0x88>
f0107077:	85 c9                	test   %ecx,%ecx
f0107079:	89 ce                	mov    %ecx,%esi
f010707b:	75 0b                	jne    f0107088 <__udivdi3+0x38>
f010707d:	b8 01 00 00 00       	mov    $0x1,%eax
f0107082:	31 d2                	xor    %edx,%edx
f0107084:	f7 f1                	div    %ecx
f0107086:	89 c6                	mov    %eax,%esi
f0107088:	31 d2                	xor    %edx,%edx
f010708a:	89 e8                	mov    %ebp,%eax
f010708c:	f7 f6                	div    %esi
f010708e:	89 c5                	mov    %eax,%ebp
f0107090:	89 f8                	mov    %edi,%eax
f0107092:	f7 f6                	div    %esi
f0107094:	89 ea                	mov    %ebp,%edx
f0107096:	83 c4 0c             	add    $0xc,%esp
f0107099:	5e                   	pop    %esi
f010709a:	5f                   	pop    %edi
f010709b:	5d                   	pop    %ebp
f010709c:	c3                   	ret    
f010709d:	8d 76 00             	lea    0x0(%esi),%esi
f01070a0:	39 e8                	cmp    %ebp,%eax
f01070a2:	77 24                	ja     f01070c8 <__udivdi3+0x78>
f01070a4:	0f bd e8             	bsr    %eax,%ebp
f01070a7:	83 f5 1f             	xor    $0x1f,%ebp
f01070aa:	75 3c                	jne    f01070e8 <__udivdi3+0x98>
f01070ac:	8b 74 24 04          	mov    0x4(%esp),%esi
f01070b0:	39 34 24             	cmp    %esi,(%esp)
f01070b3:	0f 86 9f 00 00 00    	jbe    f0107158 <__udivdi3+0x108>
f01070b9:	39 d0                	cmp    %edx,%eax
f01070bb:	0f 82 97 00 00 00    	jb     f0107158 <__udivdi3+0x108>
f01070c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01070c8:	31 d2                	xor    %edx,%edx
f01070ca:	31 c0                	xor    %eax,%eax
f01070cc:	83 c4 0c             	add    $0xc,%esp
f01070cf:	5e                   	pop    %esi
f01070d0:	5f                   	pop    %edi
f01070d1:	5d                   	pop    %ebp
f01070d2:	c3                   	ret    
f01070d3:	90                   	nop
f01070d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01070d8:	89 f8                	mov    %edi,%eax
f01070da:	f7 f1                	div    %ecx
f01070dc:	31 d2                	xor    %edx,%edx
f01070de:	83 c4 0c             	add    $0xc,%esp
f01070e1:	5e                   	pop    %esi
f01070e2:	5f                   	pop    %edi
f01070e3:	5d                   	pop    %ebp
f01070e4:	c3                   	ret    
f01070e5:	8d 76 00             	lea    0x0(%esi),%esi
f01070e8:	89 e9                	mov    %ebp,%ecx
f01070ea:	8b 3c 24             	mov    (%esp),%edi
f01070ed:	d3 e0                	shl    %cl,%eax
f01070ef:	89 c6                	mov    %eax,%esi
f01070f1:	b8 20 00 00 00       	mov    $0x20,%eax
f01070f6:	29 e8                	sub    %ebp,%eax
f01070f8:	89 c1                	mov    %eax,%ecx
f01070fa:	d3 ef                	shr    %cl,%edi
f01070fc:	89 e9                	mov    %ebp,%ecx
f01070fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0107102:	8b 3c 24             	mov    (%esp),%edi
f0107105:	09 74 24 08          	or     %esi,0x8(%esp)
f0107109:	89 d6                	mov    %edx,%esi
f010710b:	d3 e7                	shl    %cl,%edi
f010710d:	89 c1                	mov    %eax,%ecx
f010710f:	89 3c 24             	mov    %edi,(%esp)
f0107112:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0107116:	d3 ee                	shr    %cl,%esi
f0107118:	89 e9                	mov    %ebp,%ecx
f010711a:	d3 e2                	shl    %cl,%edx
f010711c:	89 c1                	mov    %eax,%ecx
f010711e:	d3 ef                	shr    %cl,%edi
f0107120:	09 d7                	or     %edx,%edi
f0107122:	89 f2                	mov    %esi,%edx
f0107124:	89 f8                	mov    %edi,%eax
f0107126:	f7 74 24 08          	divl   0x8(%esp)
f010712a:	89 d6                	mov    %edx,%esi
f010712c:	89 c7                	mov    %eax,%edi
f010712e:	f7 24 24             	mull   (%esp)
f0107131:	39 d6                	cmp    %edx,%esi
f0107133:	89 14 24             	mov    %edx,(%esp)
f0107136:	72 30                	jb     f0107168 <__udivdi3+0x118>
f0107138:	8b 54 24 04          	mov    0x4(%esp),%edx
f010713c:	89 e9                	mov    %ebp,%ecx
f010713e:	d3 e2                	shl    %cl,%edx
f0107140:	39 c2                	cmp    %eax,%edx
f0107142:	73 05                	jae    f0107149 <__udivdi3+0xf9>
f0107144:	3b 34 24             	cmp    (%esp),%esi
f0107147:	74 1f                	je     f0107168 <__udivdi3+0x118>
f0107149:	89 f8                	mov    %edi,%eax
f010714b:	31 d2                	xor    %edx,%edx
f010714d:	e9 7a ff ff ff       	jmp    f01070cc <__udivdi3+0x7c>
f0107152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107158:	31 d2                	xor    %edx,%edx
f010715a:	b8 01 00 00 00       	mov    $0x1,%eax
f010715f:	e9 68 ff ff ff       	jmp    f01070cc <__udivdi3+0x7c>
f0107164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107168:	8d 47 ff             	lea    -0x1(%edi),%eax
f010716b:	31 d2                	xor    %edx,%edx
f010716d:	83 c4 0c             	add    $0xc,%esp
f0107170:	5e                   	pop    %esi
f0107171:	5f                   	pop    %edi
f0107172:	5d                   	pop    %ebp
f0107173:	c3                   	ret    
f0107174:	66 90                	xchg   %ax,%ax
f0107176:	66 90                	xchg   %ax,%ax
f0107178:	66 90                	xchg   %ax,%ax
f010717a:	66 90                	xchg   %ax,%ax
f010717c:	66 90                	xchg   %ax,%ax
f010717e:	66 90                	xchg   %ax,%ax

f0107180 <__umoddi3>:
f0107180:	55                   	push   %ebp
f0107181:	57                   	push   %edi
f0107182:	56                   	push   %esi
f0107183:	83 ec 14             	sub    $0x14,%esp
f0107186:	8b 44 24 28          	mov    0x28(%esp),%eax
f010718a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010718e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0107192:	89 c7                	mov    %eax,%edi
f0107194:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107198:	8b 44 24 30          	mov    0x30(%esp),%eax
f010719c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01071a0:	89 34 24             	mov    %esi,(%esp)
f01071a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01071a7:	85 c0                	test   %eax,%eax
f01071a9:	89 c2                	mov    %eax,%edx
f01071ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01071af:	75 17                	jne    f01071c8 <__umoddi3+0x48>
f01071b1:	39 fe                	cmp    %edi,%esi
f01071b3:	76 4b                	jbe    f0107200 <__umoddi3+0x80>
f01071b5:	89 c8                	mov    %ecx,%eax
f01071b7:	89 fa                	mov    %edi,%edx
f01071b9:	f7 f6                	div    %esi
f01071bb:	89 d0                	mov    %edx,%eax
f01071bd:	31 d2                	xor    %edx,%edx
f01071bf:	83 c4 14             	add    $0x14,%esp
f01071c2:	5e                   	pop    %esi
f01071c3:	5f                   	pop    %edi
f01071c4:	5d                   	pop    %ebp
f01071c5:	c3                   	ret    
f01071c6:	66 90                	xchg   %ax,%ax
f01071c8:	39 f8                	cmp    %edi,%eax
f01071ca:	77 54                	ja     f0107220 <__umoddi3+0xa0>
f01071cc:	0f bd e8             	bsr    %eax,%ebp
f01071cf:	83 f5 1f             	xor    $0x1f,%ebp
f01071d2:	75 5c                	jne    f0107230 <__umoddi3+0xb0>
f01071d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01071d8:	39 3c 24             	cmp    %edi,(%esp)
f01071db:	0f 87 e7 00 00 00    	ja     f01072c8 <__umoddi3+0x148>
f01071e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01071e5:	29 f1                	sub    %esi,%ecx
f01071e7:	19 c7                	sbb    %eax,%edi
f01071e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01071ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01071f1:	8b 44 24 08          	mov    0x8(%esp),%eax
f01071f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01071f9:	83 c4 14             	add    $0x14,%esp
f01071fc:	5e                   	pop    %esi
f01071fd:	5f                   	pop    %edi
f01071fe:	5d                   	pop    %ebp
f01071ff:	c3                   	ret    
f0107200:	85 f6                	test   %esi,%esi
f0107202:	89 f5                	mov    %esi,%ebp
f0107204:	75 0b                	jne    f0107211 <__umoddi3+0x91>
f0107206:	b8 01 00 00 00       	mov    $0x1,%eax
f010720b:	31 d2                	xor    %edx,%edx
f010720d:	f7 f6                	div    %esi
f010720f:	89 c5                	mov    %eax,%ebp
f0107211:	8b 44 24 04          	mov    0x4(%esp),%eax
f0107215:	31 d2                	xor    %edx,%edx
f0107217:	f7 f5                	div    %ebp
f0107219:	89 c8                	mov    %ecx,%eax
f010721b:	f7 f5                	div    %ebp
f010721d:	eb 9c                	jmp    f01071bb <__umoddi3+0x3b>
f010721f:	90                   	nop
f0107220:	89 c8                	mov    %ecx,%eax
f0107222:	89 fa                	mov    %edi,%edx
f0107224:	83 c4 14             	add    $0x14,%esp
f0107227:	5e                   	pop    %esi
f0107228:	5f                   	pop    %edi
f0107229:	5d                   	pop    %ebp
f010722a:	c3                   	ret    
f010722b:	90                   	nop
f010722c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107230:	8b 04 24             	mov    (%esp),%eax
f0107233:	be 20 00 00 00       	mov    $0x20,%esi
f0107238:	89 e9                	mov    %ebp,%ecx
f010723a:	29 ee                	sub    %ebp,%esi
f010723c:	d3 e2                	shl    %cl,%edx
f010723e:	89 f1                	mov    %esi,%ecx
f0107240:	d3 e8                	shr    %cl,%eax
f0107242:	89 e9                	mov    %ebp,%ecx
f0107244:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107248:	8b 04 24             	mov    (%esp),%eax
f010724b:	09 54 24 04          	or     %edx,0x4(%esp)
f010724f:	89 fa                	mov    %edi,%edx
f0107251:	d3 e0                	shl    %cl,%eax
f0107253:	89 f1                	mov    %esi,%ecx
f0107255:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107259:	8b 44 24 10          	mov    0x10(%esp),%eax
f010725d:	d3 ea                	shr    %cl,%edx
f010725f:	89 e9                	mov    %ebp,%ecx
f0107261:	d3 e7                	shl    %cl,%edi
f0107263:	89 f1                	mov    %esi,%ecx
f0107265:	d3 e8                	shr    %cl,%eax
f0107267:	89 e9                	mov    %ebp,%ecx
f0107269:	09 f8                	or     %edi,%eax
f010726b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010726f:	f7 74 24 04          	divl   0x4(%esp)
f0107273:	d3 e7                	shl    %cl,%edi
f0107275:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107279:	89 d7                	mov    %edx,%edi
f010727b:	f7 64 24 08          	mull   0x8(%esp)
f010727f:	39 d7                	cmp    %edx,%edi
f0107281:	89 c1                	mov    %eax,%ecx
f0107283:	89 14 24             	mov    %edx,(%esp)
f0107286:	72 2c                	jb     f01072b4 <__umoddi3+0x134>
f0107288:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010728c:	72 22                	jb     f01072b0 <__umoddi3+0x130>
f010728e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0107292:	29 c8                	sub    %ecx,%eax
f0107294:	19 d7                	sbb    %edx,%edi
f0107296:	89 e9                	mov    %ebp,%ecx
f0107298:	89 fa                	mov    %edi,%edx
f010729a:	d3 e8                	shr    %cl,%eax
f010729c:	89 f1                	mov    %esi,%ecx
f010729e:	d3 e2                	shl    %cl,%edx
f01072a0:	89 e9                	mov    %ebp,%ecx
f01072a2:	d3 ef                	shr    %cl,%edi
f01072a4:	09 d0                	or     %edx,%eax
f01072a6:	89 fa                	mov    %edi,%edx
f01072a8:	83 c4 14             	add    $0x14,%esp
f01072ab:	5e                   	pop    %esi
f01072ac:	5f                   	pop    %edi
f01072ad:	5d                   	pop    %ebp
f01072ae:	c3                   	ret    
f01072af:	90                   	nop
f01072b0:	39 d7                	cmp    %edx,%edi
f01072b2:	75 da                	jne    f010728e <__umoddi3+0x10e>
f01072b4:	8b 14 24             	mov    (%esp),%edx
f01072b7:	89 c1                	mov    %eax,%ecx
f01072b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f01072bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
f01072c1:	eb cb                	jmp    f010728e <__umoddi3+0x10e>
f01072c3:	90                   	nop
f01072c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01072c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01072cc:	0f 82 0f ff ff ff    	jb     f01071e1 <__umoddi3+0x61>
f01072d2:	e9 1a ff ff ff       	jmp    f01071f1 <__umoddi3+0x71>
