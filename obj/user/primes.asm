
obj/user/primes:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800046:	00 
  800047:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004e:	00 
  80004f:	89 34 24             	mov    %esi,(%esp)
  800052:	e8 09 12 00 00       	call   801260 <ipc_recv>
  800057:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800059:	a1 04 20 80 00       	mov    0x802004,%eax
  80005e:	8b 40 5c             	mov    0x5c(%eax),%eax
  800061:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	c7 04 24 c0 16 80 00 	movl   $0x8016c0,(%esp)
  800070:	e8 28 02 00 00       	call   80029d <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800075:	e8 ba 0f 00 00       	call   801034 <fork>
  80007a:	89 c7                	mov    %eax,%edi
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 20                	jns    8000a0 <primeproc+0x6d>
		panic("fork: %e", id);
  800080:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800084:	c7 44 24 08 cc 16 80 	movl   $0x8016cc,0x8(%esp)
  80008b:	00 
  80008c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800093:	00 
  800094:	c7 04 24 d5 16 80 00 	movl   $0x8016d5,(%esp)
  80009b:	e8 04 01 00 00       	call   8001a4 <_panic>
	if (id == 0)
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	74 9b                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a4:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	89 34 24             	mov    %esi,(%esp)
  8000ba:	e8 a1 11 00 00       	call   801260 <ipc_recv>
  8000bf:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c1:	99                   	cltd   
  8000c2:	f7 fb                	idiv   %ebx
  8000c4:	85 d2                	test   %edx,%edx
  8000c6:	74 df                	je     8000a7 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000cf:	00 
  8000d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d7:	00 
  8000d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dc:	89 3c 24             	mov    %edi,(%esp)
  8000df:	e8 e4 11 00 00       	call   8012c8 <ipc_send>
  8000e4:	eb c1                	jmp    8000a7 <primeproc+0x74>

008000e6 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ee:	e8 41 0f 00 00       	call   801034 <fork>
  8000f3:	89 c6                	mov    %eax,%esi
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	79 20                	jns    800119 <umain+0x33>
		panic("fork: %e", id);
  8000f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fd:	c7 44 24 08 cc 16 80 	movl   $0x8016cc,0x8(%esp)
  800104:	00 
  800105:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010c:	00 
  80010d:	c7 04 24 d5 16 80 00 	movl   $0x8016d5,(%esp)
  800114:	e8 8b 00 00 00       	call   8001a4 <_panic>
	if (id == 0)
  800119:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011e:	85 c0                	test   %eax,%eax
  800120:	75 05                	jne    800127 <umain+0x41>
		primeproc();
  800122:	e8 0c ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800127:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800136:	00 
  800137:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013b:	89 34 24             	mov    %esi,(%esp)
  80013e:	e8 85 11 00 00       	call   8012c8 <ipc_send>
	for (i = 2; ; i++)
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	eb df                	jmp    800127 <umain+0x41>

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800153:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 4a 0b 00 00       	call   800ca5 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 04 20 80 00       	mov    %eax,0x802004


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016d:	85 db                	test   %ebx,%ebx
  80016f:	7e 07                	jle    800178 <libmain+0x30>
		binaryname = argv[0];
  800171:	8b 06                	mov    (%esi),%eax
  800173:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800178:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017c:	89 1c 24             	mov    %ebx,(%esp)
  80017f:	e8 62 ff ff ff       	call   8000e6 <umain>

	// exit gracefully
	exit();
  800184:	e8 07 00 00 00       	call   800190 <exit>
}
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800196:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019d:	e8 b1 0a 00 00       	call   800c53 <sys_env_destroy>
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001ac:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001af:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001b5:	e8 eb 0a 00 00       	call   800ca5 <sys_getenvid>
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 f0 16 80 00 	movl   $0x8016f0,(%esp)
  8001d7:	e8 c1 00 00 00       	call   80029d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	e8 51 00 00 00       	call   80023c <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 c6 19 80 00 	movl   $0x8019c6,(%esp)
  8001f2:	e8 a6 00 00 00       	call   80029d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f7:	cc                   	int3   
  8001f8:	eb fd                	jmp    8001f7 <_panic+0x53>

008001fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	53                   	push   %ebx
  8001fe:	83 ec 14             	sub    $0x14,%esp
  800201:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800204:	8b 13                	mov    (%ebx),%edx
  800206:	8d 42 01             	lea    0x1(%edx),%eax
  800209:	89 03                	mov    %eax,(%ebx)
  80020b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800212:	3d ff 00 00 00       	cmp    $0xff,%eax
  800217:	75 19                	jne    800232 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800219:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800220:	00 
  800221:	8d 43 08             	lea    0x8(%ebx),%eax
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	e8 ea 09 00 00       	call   800c16 <sys_cputs>
		b->idx = 0;
  80022c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	83 c4 14             	add    $0x14,%esp
  800239:	5b                   	pop    %ebx
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    

0080023c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800245:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024c:	00 00 00 
	b.cnt = 0;
  80024f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800256:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800259:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	89 44 24 08          	mov    %eax,0x8(%esp)
  800267:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	c7 04 24 fa 01 80 00 	movl   $0x8001fa,(%esp)
  800278:	e8 b1 01 00 00       	call   80042e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800283:	89 44 24 04          	mov    %eax,0x4(%esp)
  800287:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028d:	89 04 24             	mov    %eax,(%esp)
  800290:	e8 81 09 00 00       	call   800c16 <sys_cputs>

	return b.cnt;
}
  800295:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ad:	89 04 24             	mov    %eax,(%esp)
  8002b0:	e8 87 ff ff ff       	call   80023c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    
  8002b7:	66 90                	xchg   %ax,%ax
  8002b9:	66 90                	xchg   %ax,%ax
  8002bb:	66 90                	xchg   %ax,%ax
  8002bd:	66 90                	xchg   %ax,%ax
  8002bf:	90                   	nop

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 3c             	sub    $0x3c,%esp
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	89 d7                	mov    %edx,%edi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d7:	89 c3                	mov    %eax,%ebx
  8002d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ed:	39 d9                	cmp    %ebx,%ecx
  8002ef:	72 05                	jb     8002f6 <printnum+0x36>
  8002f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002f4:	77 69                	ja     80035f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002fd:	83 ee 01             	sub    $0x1,%esi
  800300:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8b 44 24 08          	mov    0x8(%esp),%eax
  80030c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800310:	89 c3                	mov    %eax,%ebx
  800312:	89 d6                	mov    %edx,%esi
  800314:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800317:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80031a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80031e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	e8 ec 10 00 00       	call   801420 <__udivdi3>
  800334:	89 d9                	mov    %ebx,%ecx
  800336:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033e:	89 04 24             	mov    %eax,(%esp)
  800341:	89 54 24 04          	mov    %edx,0x4(%esp)
  800345:	89 fa                	mov    %edi,%edx
  800347:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034a:	e8 71 ff ff ff       	call   8002c0 <printnum>
  80034f:	eb 1b                	jmp    80036c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800351:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800355:	8b 45 18             	mov    0x18(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	ff d3                	call   *%ebx
  80035d:	eb 03                	jmp    800362 <printnum+0xa2>
  80035f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800362:	83 ee 01             	sub    $0x1,%esi
  800365:	85 f6                	test   %esi,%esi
  800367:	7f e8                	jg     800351 <printnum+0x91>
  800369:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800370:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800374:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800377:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80037a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800385:	89 04 24             	mov    %eax,(%esp)
  800388:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038f:	e8 bc 11 00 00       	call   801550 <__umoddi3>
  800394:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800398:	0f be 80 13 17 80 00 	movsbl 0x801713(%eax),%eax
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003a5:	ff d0                	call   *%eax
}
  8003a7:	83 c4 3c             	add    $0x3c,%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b2:	83 fa 01             	cmp    $0x1,%edx
  8003b5:	7e 0e                	jle    8003c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003bc:	89 08                	mov    %ecx,(%eax)
  8003be:	8b 02                	mov    (%edx),%eax
  8003c0:	8b 52 04             	mov    0x4(%edx),%edx
  8003c3:	eb 22                	jmp    8003e7 <getuint+0x38>
	else if (lflag)
  8003c5:	85 d2                	test   %edx,%edx
  8003c7:	74 10                	je     8003d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ce:	89 08                	mov    %ecx,(%eax)
  8003d0:	8b 02                	mov    (%edx),%eax
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	eb 0e                	jmp    8003e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 02                	mov    (%edx),%eax
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f8:	73 0a                	jae    800404 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	88 02                	mov    %al,(%edx)
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <printfmt>:
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80040c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800413:	8b 45 10             	mov    0x10(%ebp),%eax
  800416:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	e8 02 00 00 00       	call   80042e <vprintfmt>
}
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <vprintfmt>:
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	57                   	push   %edi
  800432:	56                   	push   %esi
  800433:	53                   	push   %ebx
  800434:	83 ec 3c             	sub    $0x3c,%esp
  800437:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80043a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80043d:	eb 14                	jmp    800453 <vprintfmt+0x25>
			if (ch == '\0'){
  80043f:	85 c0                	test   %eax,%eax
  800441:	0f 84 b3 03 00 00    	je     8007fa <vprintfmt+0x3cc>
			putch(ch, putdat);
  800447:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044b:	89 04 24             	mov    %eax,(%esp)
  80044e:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800451:	89 f3                	mov    %esi,%ebx
  800453:	8d 73 01             	lea    0x1(%ebx),%esi
  800456:	0f b6 03             	movzbl (%ebx),%eax
  800459:	83 f8 25             	cmp    $0x25,%eax
  80045c:	75 e1                	jne    80043f <vprintfmt+0x11>
  80045e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800462:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800469:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800470:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800477:	ba 00 00 00 00       	mov    $0x0,%edx
  80047c:	eb 1d                	jmp    80049b <vprintfmt+0x6d>
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	89 de                	mov    %ebx,%esi
			padc = '-';
  800480:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800484:	eb 15                	jmp    80049b <vprintfmt+0x6d>
		switch (ch = *(unsigned char *) fmt++) {
  800486:	89 de                	mov    %ebx,%esi
			padc = '0';
  800488:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80048c:	eb 0d                	jmp    80049b <vprintfmt+0x6d>
				width = precision, precision = -1;
  80048e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800491:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800494:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80049e:	0f b6 0e             	movzbl (%esi),%ecx
  8004a1:	0f b6 c1             	movzbl %cl,%eax
  8004a4:	83 e9 23             	sub    $0x23,%ecx
  8004a7:	80 f9 55             	cmp    $0x55,%cl
  8004aa:	0f 87 2a 03 00 00    	ja     8007da <vprintfmt+0x3ac>
  8004b0:	0f b6 c9             	movzbl %cl,%ecx
  8004b3:	ff 24 8d e0 17 80 00 	jmp    *0x8017e0(,%ecx,4)
  8004ba:	89 de                	mov    %ebx,%esi
  8004bc:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8004c1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004c4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004c8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004cb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ce:	83 fb 09             	cmp    $0x9,%ebx
  8004d1:	77 36                	ja     800509 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  8004d3:	83 c6 01             	add    $0x1,%esi
			}
  8004d6:	eb e9                	jmp    8004c1 <vprintfmt+0x93>
			precision = va_arg(ap, int);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 48 04             	lea    0x4(%eax),%ecx
  8004de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e1:	8b 00                	mov    (%eax),%eax
  8004e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	89 de                	mov    %ebx,%esi
			goto process_precision;
  8004e8:	eb 22                	jmp    80050c <vprintfmt+0xde>
  8004ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f4:	0f 49 c1             	cmovns %ecx,%eax
  8004f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	89 de                	mov    %ebx,%esi
  8004fc:	eb 9d                	jmp    80049b <vprintfmt+0x6d>
  8004fe:	89 de                	mov    %ebx,%esi
			altflag = 1;
  800500:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800507:	eb 92                	jmp    80049b <vprintfmt+0x6d>
  800509:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  80050c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800510:	79 89                	jns    80049b <vprintfmt+0x6d>
  800512:	e9 77 ff ff ff       	jmp    80048e <vprintfmt+0x60>
			lflag++;
  800517:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80051c:	e9 7a ff ff ff       	jmp    80049b <vprintfmt+0x6d>
			putch(va_arg(ap, int), putdat);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 50 04             	lea    0x4(%eax),%edx
  800527:	89 55 14             	mov    %edx,0x14(%ebp)
  80052a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	ff 55 08             	call   *0x8(%ebp)
			break;
  800536:	e9 18 ff ff ff       	jmp    800453 <vprintfmt+0x25>
			err = va_arg(ap, int);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 00                	mov    (%eax),%eax
  800546:	99                   	cltd   
  800547:	31 d0                	xor    %edx,%eax
  800549:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054b:	83 f8 08             	cmp    $0x8,%eax
  80054e:	7f 0b                	jg     80055b <vprintfmt+0x12d>
  800550:	8b 14 85 40 19 80 00 	mov    0x801940(,%eax,4),%edx
  800557:	85 d2                	test   %edx,%edx
  800559:	75 20                	jne    80057b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80055b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055f:	c7 44 24 08 2b 17 80 	movl   $0x80172b,0x8(%esp)
  800566:	00 
  800567:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056b:	8b 45 08             	mov    0x8(%ebp),%eax
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	e8 90 fe ff ff       	call   800406 <printfmt>
  800576:	e9 d8 fe ff ff       	jmp    800453 <vprintfmt+0x25>
				printfmt(putch, putdat, "%s", p);
  80057b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80057f:	c7 44 24 08 34 17 80 	movl   $0x801734,0x8(%esp)
  800586:	00 
  800587:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058b:	8b 45 08             	mov    0x8(%ebp),%eax
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	e8 70 fe ff ff       	call   800406 <printfmt>
  800596:	e9 b8 fe ff ff       	jmp    800453 <vprintfmt+0x25>
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80059e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005af:	85 f6                	test   %esi,%esi
  8005b1:	b8 24 17 80 00       	mov    $0x801724,%eax
  8005b6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005bd:	0f 84 97 00 00 00    	je     80065a <vprintfmt+0x22c>
  8005c3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005c7:	0f 8e 9b 00 00 00    	jle    800668 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d1:	89 34 24             	mov    %esi,(%esp)
  8005d4:	e8 cf 02 00 00       	call   8008a8 <strnlen>
  8005d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005dc:	29 c2                	sub    %eax,%edx
  8005de:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  8005e1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005f1:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	eb 0f                	jmp    800604 <vprintfmt+0x1d6>
					putch(padc, putdat);
  8005f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005fc:	89 04 24             	mov    %eax,(%esp)
  8005ff:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800601:	83 eb 01             	sub    $0x1,%ebx
  800604:	85 db                	test   %ebx,%ebx
  800606:	7f ed                	jg     8005f5 <vprintfmt+0x1c7>
  800608:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80060b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80060e:	85 d2                	test   %edx,%edx
  800610:	b8 00 00 00 00       	mov    $0x0,%eax
  800615:	0f 49 c2             	cmovns %edx,%eax
  800618:	29 c2                	sub    %eax,%edx
  80061a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80061d:	89 d7                	mov    %edx,%edi
  80061f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800622:	eb 50                	jmp    800674 <vprintfmt+0x246>
				if (altflag && (ch < ' ' || ch > '~'))
  800624:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800628:	74 1e                	je     800648 <vprintfmt+0x21a>
  80062a:	0f be d2             	movsbl %dl,%edx
  80062d:	83 ea 20             	sub    $0x20,%edx
  800630:	83 fa 5e             	cmp    $0x5e,%edx
  800633:	76 13                	jbe    800648 <vprintfmt+0x21a>
					putch('?', putdat);
  800635:	8b 45 0c             	mov    0xc(%ebp),%eax
  800638:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
  800646:	eb 0d                	jmp    800655 <vprintfmt+0x227>
					putch(ch, putdat);
  800648:	8b 55 0c             	mov    0xc(%ebp),%edx
  80064b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800655:	83 ef 01             	sub    $0x1,%edi
  800658:	eb 1a                	jmp    800674 <vprintfmt+0x246>
  80065a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80065d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800660:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800663:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800666:	eb 0c                	jmp    800674 <vprintfmt+0x246>
  800668:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80066b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80066e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800671:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800674:	83 c6 01             	add    $0x1,%esi
  800677:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80067b:	0f be c2             	movsbl %dl,%eax
  80067e:	85 c0                	test   %eax,%eax
  800680:	74 27                	je     8006a9 <vprintfmt+0x27b>
  800682:	85 db                	test   %ebx,%ebx
  800684:	78 9e                	js     800624 <vprintfmt+0x1f6>
  800686:	83 eb 01             	sub    $0x1,%ebx
  800689:	79 99                	jns    800624 <vprintfmt+0x1f6>
  80068b:	89 f8                	mov    %edi,%eax
  80068d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800690:	8b 75 08             	mov    0x8(%ebp),%esi
  800693:	89 c3                	mov    %eax,%ebx
  800695:	eb 1a                	jmp    8006b1 <vprintfmt+0x283>
				putch(' ', putdat);
  800697:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006a4:	83 eb 01             	sub    $0x1,%ebx
  8006a7:	eb 08                	jmp    8006b1 <vprintfmt+0x283>
  8006a9:	89 fb                	mov    %edi,%ebx
  8006ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006b1:	85 db                	test   %ebx,%ebx
  8006b3:	7f e2                	jg     800697 <vprintfmt+0x269>
  8006b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006bb:	e9 93 fd ff ff       	jmp    800453 <vprintfmt+0x25>
	if (lflag >= 2)
  8006c0:	83 fa 01             	cmp    $0x1,%edx
  8006c3:	7e 16                	jle    8006db <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 08             	lea    0x8(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	8b 50 04             	mov    0x4(%eax),%edx
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006d9:	eb 32                	jmp    80070d <vprintfmt+0x2df>
	else if (lflag)
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	74 18                	je     8006f7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 04             	lea    0x4(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 30                	mov    (%eax),%esi
  8006ea:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006ed:	89 f0                	mov    %esi,%eax
  8006ef:	c1 f8 1f             	sar    $0x1f,%eax
  8006f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f5:	eb 16                	jmp    80070d <vprintfmt+0x2df>
		return va_arg(*ap, int);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 30                	mov    (%eax),%esi
  800702:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800705:	89 f0                	mov    %esi,%eax
  800707:	c1 f8 1f             	sar    $0x1f,%eax
  80070a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  80070d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800710:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  800713:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800718:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80071c:	0f 89 80 00 00 00    	jns    8007a2 <vprintfmt+0x374>
				putch('-', putdat);
  800722:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800726:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800730:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800733:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800736:	f7 d8                	neg    %eax
  800738:	83 d2 00             	adc    $0x0,%edx
  80073b:	f7 da                	neg    %edx
			base = 10;
  80073d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800742:	eb 5e                	jmp    8007a2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
  800747:	e8 63 fc ff ff       	call   8003af <getuint>
			base = 10;
  80074c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800751:	eb 4f                	jmp    8007a2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
  800756:	e8 54 fc ff ff       	call   8003af <getuint>
      		base = 8;
  80075b:	b9 08 00 00 00       	mov    $0x8,%ecx
      		goto number;
  800760:	eb 40                	jmp    8007a2 <vprintfmt+0x374>
			putch('0', putdat);
  800762:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800766:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80076d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800770:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800774:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80077b:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8d 50 04             	lea    0x4(%eax),%edx
  800784:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800787:	8b 00                	mov    (%eax),%eax
  800789:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  80078e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800793:	eb 0d                	jmp    8007a2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800795:	8d 45 14             	lea    0x14(%ebp),%eax
  800798:	e8 12 fc ff ff       	call   8003af <getuint>
			base = 16;
  80079d:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8007a2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8007a6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007aa:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007ad:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007b5:	89 04 24             	mov    %eax,(%esp)
  8007b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007bc:	89 fa                	mov    %edi,%edx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	e8 fa fa ff ff       	call   8002c0 <printnum>
			break;
  8007c6:	e9 88 fc ff ff       	jmp    800453 <vprintfmt+0x25>
			putch(ch, putdat);
  8007cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007d5:	e9 79 fc ff ff       	jmp    800453 <vprintfmt+0x25>
			putch('%', putdat);
  8007da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e8:	89 f3                	mov    %esi,%ebx
  8007ea:	eb 03                	jmp    8007ef <vprintfmt+0x3c1>
  8007ec:	83 eb 01             	sub    $0x1,%ebx
  8007ef:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007f3:	75 f7                	jne    8007ec <vprintfmt+0x3be>
  8007f5:	e9 59 fc ff ff       	jmp    800453 <vprintfmt+0x25>
}
  8007fa:	83 c4 3c             	add    $0x3c,%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 28             	sub    $0x28,%esp
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800811:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800815:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800818:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081f:	85 c0                	test   %eax,%eax
  800821:	74 30                	je     800853 <vsnprintf+0x51>
  800823:	85 d2                	test   %edx,%edx
  800825:	7e 2c                	jle    800853 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800827:	8b 45 14             	mov    0x14(%ebp),%eax
  80082a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082e:	8b 45 10             	mov    0x10(%ebp),%eax
  800831:	89 44 24 08          	mov    %eax,0x8(%esp)
  800835:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083c:	c7 04 24 e9 03 80 00 	movl   $0x8003e9,(%esp)
  800843:	e8 e6 fb ff ff       	call   80042e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800848:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800851:	eb 05                	jmp    800858 <vsnprintf+0x56>
		return -E_INVAL;
  800853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800860:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800863:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800867:	8b 45 10             	mov    0x10(%ebp),%eax
  80086a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800871:	89 44 24 04          	mov    %eax,0x4(%esp)
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	e8 82 ff ff ff       	call   800802 <vsnprintf>
	va_end(ap);

	return rc;
}
  800880:	c9                   	leave  
  800881:	c3                   	ret    
  800882:	66 90                	xchg   %ax,%ax
  800884:	66 90                	xchg   %ax,%ax
  800886:	66 90                	xchg   %ax,%ax
  800888:	66 90                	xchg   %ax,%ax
  80088a:	66 90                	xchg   %ax,%ax
  80088c:	66 90                	xchg   %ax,%ax
  80088e:	66 90                	xchg   %ax,%ax

00800890 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	eb 03                	jmp    8008a0 <strlen+0x10>
		n++;
  80089d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a4:	75 f7                	jne    80089d <strlen+0xd>
	return n;
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	eb 03                	jmp    8008bb <strnlen+0x13>
		n++;
  8008b8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bb:	39 d0                	cmp    %edx,%eax
  8008bd:	74 06                	je     8008c5 <strnlen+0x1d>
  8008bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c3:	75 f3                	jne    8008b8 <strnlen+0x10>
	return n;
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d1:	89 c2                	mov    %eax,%edx
  8008d3:	83 c2 01             	add    $0x1,%edx
  8008d6:	83 c1 01             	add    $0x1,%ecx
  8008d9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008dd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e0:	84 db                	test   %bl,%bl
  8008e2:	75 ef                	jne    8008d3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	53                   	push   %ebx
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f1:	89 1c 24             	mov    %ebx,(%esp)
  8008f4:	e8 97 ff ff ff       	call   800890 <strlen>
	strcpy(dst + len, src);
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800900:	01 d8                	add    %ebx,%eax
  800902:	89 04 24             	mov    %eax,(%esp)
  800905:	e8 bd ff ff ff       	call   8008c7 <strcpy>
	return dst;
}
  80090a:	89 d8                	mov    %ebx,%eax
  80090c:	83 c4 08             	add    $0x8,%esp
  80090f:	5b                   	pop    %ebx
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 75 08             	mov    0x8(%ebp),%esi
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091d:	89 f3                	mov    %esi,%ebx
  80091f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800922:	89 f2                	mov    %esi,%edx
  800924:	eb 0f                	jmp    800935 <strncpy+0x23>
		*dst++ = *src;
  800926:	83 c2 01             	add    $0x1,%edx
  800929:	0f b6 01             	movzbl (%ecx),%eax
  80092c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092f:	80 39 01             	cmpb   $0x1,(%ecx)
  800932:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800935:	39 da                	cmp    %ebx,%edx
  800937:	75 ed                	jne    800926 <strncpy+0x14>
	}
	return ret;
}
  800939:	89 f0                	mov    %esi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 75 08             	mov    0x8(%ebp),%esi
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80094d:	89 f0                	mov    %esi,%eax
  80094f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800953:	85 c9                	test   %ecx,%ecx
  800955:	75 0b                	jne    800962 <strlcpy+0x23>
  800957:	eb 1d                	jmp    800976 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800959:	83 c0 01             	add    $0x1,%eax
  80095c:	83 c2 01             	add    $0x1,%edx
  80095f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800962:	39 d8                	cmp    %ebx,%eax
  800964:	74 0b                	je     800971 <strlcpy+0x32>
  800966:	0f b6 0a             	movzbl (%edx),%ecx
  800969:	84 c9                	test   %cl,%cl
  80096b:	75 ec                	jne    800959 <strlcpy+0x1a>
  80096d:	89 c2                	mov    %eax,%edx
  80096f:	eb 02                	jmp    800973 <strlcpy+0x34>
  800971:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800973:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800976:	29 f0                	sub    %esi,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800985:	eb 06                	jmp    80098d <strcmp+0x11>
		p++, q++;
  800987:	83 c1 01             	add    $0x1,%ecx
  80098a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80098d:	0f b6 01             	movzbl (%ecx),%eax
  800990:	84 c0                	test   %al,%al
  800992:	74 04                	je     800998 <strcmp+0x1c>
  800994:	3a 02                	cmp    (%edx),%al
  800996:	74 ef                	je     800987 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 c0             	movzbl %al,%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	89 c3                	mov    %eax,%ebx
  8009ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b1:	eb 06                	jmp    8009b9 <strncmp+0x17>
		n--, p++, q++;
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b9:	39 d8                	cmp    %ebx,%eax
  8009bb:	74 15                	je     8009d2 <strncmp+0x30>
  8009bd:	0f b6 08             	movzbl (%eax),%ecx
  8009c0:	84 c9                	test   %cl,%cl
  8009c2:	74 04                	je     8009c8 <strncmp+0x26>
  8009c4:	3a 0a                	cmp    (%edx),%cl
  8009c6:	74 eb                	je     8009b3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c8:	0f b6 00             	movzbl (%eax),%eax
  8009cb:	0f b6 12             	movzbl (%edx),%edx
  8009ce:	29 d0                	sub    %edx,%eax
  8009d0:	eb 05                	jmp    8009d7 <strncmp+0x35>
		return 0;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e4:	eb 07                	jmp    8009ed <strchr+0x13>
		if (*s == c)
  8009e6:	38 ca                	cmp    %cl,%dl
  8009e8:	74 0f                	je     8009f9 <strchr+0x1f>
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 f2                	jne    8009e6 <strchr+0xc>
			return (char *) s;
	return 0;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a05:	eb 07                	jmp    800a0e <strfind+0x13>
		if (*s == c)
  800a07:	38 ca                	cmp    %cl,%dl
  800a09:	74 0a                	je     800a15 <strfind+0x1a>
	for (; *s; s++)
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	84 d2                	test   %dl,%dl
  800a13:	75 f2                	jne    800a07 <strfind+0xc>
			break;
	return (char *) s;
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a23:	85 c9                	test   %ecx,%ecx
  800a25:	74 36                	je     800a5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2d:	75 28                	jne    800a57 <memset+0x40>
  800a2f:	f6 c1 03             	test   $0x3,%cl
  800a32:	75 23                	jne    800a57 <memset+0x40>
		c &= 0xFF;
  800a34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a38:	89 d3                	mov    %edx,%ebx
  800a3a:	c1 e3 08             	shl    $0x8,%ebx
  800a3d:	89 d6                	mov    %edx,%esi
  800a3f:	c1 e6 18             	shl    $0x18,%esi
  800a42:	89 d0                	mov    %edx,%eax
  800a44:	c1 e0 10             	shl    $0x10,%eax
  800a47:	09 f0                	or     %esi,%eax
  800a49:	09 c2                	or     %eax,%edx
  800a4b:	89 d0                	mov    %edx,%eax
  800a4d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a4f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a52:	fc                   	cld    
  800a53:	f3 ab                	rep stos %eax,%es:(%edi)
  800a55:	eb 06                	jmp    800a5d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5a:	fc                   	cld    
  800a5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a5d:	89 f8                	mov    %edi,%eax
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a72:	39 c6                	cmp    %eax,%esi
  800a74:	73 35                	jae    800aab <memmove+0x47>
  800a76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a79:	39 d0                	cmp    %edx,%eax
  800a7b:	73 2e                	jae    800aab <memmove+0x47>
		s += n;
		d += n;
  800a7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a80:	89 d6                	mov    %edx,%esi
  800a82:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8a:	75 13                	jne    800a9f <memmove+0x3b>
  800a8c:	f6 c1 03             	test   $0x3,%cl
  800a8f:	75 0e                	jne    800a9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a91:	83 ef 04             	sub    $0x4,%edi
  800a94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a9a:	fd                   	std    
  800a9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9d:	eb 09                	jmp    800aa8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9f:	83 ef 01             	sub    $0x1,%edi
  800aa2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa5:	fd                   	std    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa8:	fc                   	cld    
  800aa9:	eb 1d                	jmp    800ac8 <memmove+0x64>
  800aab:	89 f2                	mov    %esi,%edx
  800aad:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaf:	f6 c2 03             	test   $0x3,%dl
  800ab2:	75 0f                	jne    800ac3 <memmove+0x5f>
  800ab4:	f6 c1 03             	test   $0x3,%cl
  800ab7:	75 0a                	jne    800ac3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800abc:	89 c7                	mov    %eax,%edi
  800abe:	fc                   	cld    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac1:	eb 05                	jmp    800ac8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800ac3:	89 c7                	mov    %eax,%edi
  800ac5:	fc                   	cld    
  800ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	89 04 24             	mov    %eax,(%esp)
  800ae6:	e8 79 ff ff ff       	call   800a64 <memmove>
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afd:	eb 1a                	jmp    800b19 <memcmp+0x2c>
		if (*s1 != *s2)
  800aff:	0f b6 02             	movzbl (%edx),%eax
  800b02:	0f b6 19             	movzbl (%ecx),%ebx
  800b05:	38 d8                	cmp    %bl,%al
  800b07:	74 0a                	je     800b13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b09:	0f b6 c0             	movzbl %al,%eax
  800b0c:	0f b6 db             	movzbl %bl,%ebx
  800b0f:	29 d8                	sub    %ebx,%eax
  800b11:	eb 0f                	jmp    800b22 <memcmp+0x35>
		s1++, s2++;
  800b13:	83 c2 01             	add    $0x1,%edx
  800b16:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800b19:	39 f2                	cmp    %esi,%edx
  800b1b:	75 e2                	jne    800aff <memcmp+0x12>
	}

	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b34:	eb 07                	jmp    800b3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b36:	38 08                	cmp    %cl,(%eax)
  800b38:	74 07                	je     800b41 <memfind+0x1b>
	for (; s < ends; s++)
  800b3a:	83 c0 01             	add    $0x1,%eax
  800b3d:	39 d0                	cmp    %edx,%eax
  800b3f:	72 f5                	jb     800b36 <memfind+0x10>
			break;
	return (void *) s;
}
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4f:	eb 03                	jmp    800b54 <strtol+0x11>
		s++;
  800b51:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b54:	0f b6 0a             	movzbl (%edx),%ecx
  800b57:	80 f9 09             	cmp    $0x9,%cl
  800b5a:	74 f5                	je     800b51 <strtol+0xe>
  800b5c:	80 f9 20             	cmp    $0x20,%cl
  800b5f:	74 f0                	je     800b51 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b61:	80 f9 2b             	cmp    $0x2b,%cl
  800b64:	75 0a                	jne    800b70 <strtol+0x2d>
		s++;
  800b66:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6e:	eb 11                	jmp    800b81 <strtol+0x3e>
  800b70:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800b75:	80 f9 2d             	cmp    $0x2d,%cl
  800b78:	75 07                	jne    800b81 <strtol+0x3e>
		s++, neg = 1;
  800b7a:	8d 52 01             	lea    0x1(%edx),%edx
  800b7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b86:	75 15                	jne    800b9d <strtol+0x5a>
  800b88:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8b:	75 10                	jne    800b9d <strtol+0x5a>
  800b8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b91:	75 0a                	jne    800b9d <strtol+0x5a>
		s += 2, base = 16;
  800b93:	83 c2 02             	add    $0x2,%edx
  800b96:	b8 10 00 00 00       	mov    $0x10,%eax
  800b9b:	eb 10                	jmp    800bad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	75 0c                	jne    800bad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800ba3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba6:	75 05                	jne    800bad <strtol+0x6a>
		s++, base = 8;
  800ba8:	83 c2 01             	add    $0x1,%edx
  800bab:	b0 08                	mov    $0x8,%al
		base = 10;
  800bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb5:	0f b6 0a             	movzbl (%edx),%ecx
  800bb8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800bbb:	89 f0                	mov    %esi,%eax
  800bbd:	3c 09                	cmp    $0x9,%al
  800bbf:	77 08                	ja     800bc9 <strtol+0x86>
			dig = *s - '0';
  800bc1:	0f be c9             	movsbl %cl,%ecx
  800bc4:	83 e9 30             	sub    $0x30,%ecx
  800bc7:	eb 20                	jmp    800be9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800bc9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bcc:	89 f0                	mov    %esi,%eax
  800bce:	3c 19                	cmp    $0x19,%al
  800bd0:	77 08                	ja     800bda <strtol+0x97>
			dig = *s - 'a' + 10;
  800bd2:	0f be c9             	movsbl %cl,%ecx
  800bd5:	83 e9 57             	sub    $0x57,%ecx
  800bd8:	eb 0f                	jmp    800be9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bda:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bdd:	89 f0                	mov    %esi,%eax
  800bdf:	3c 19                	cmp    $0x19,%al
  800be1:	77 16                	ja     800bf9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800be3:	0f be c9             	movsbl %cl,%ecx
  800be6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800be9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bec:	7d 0f                	jge    800bfd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bee:	83 c2 01             	add    $0x1,%edx
  800bf1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bf5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bf7:	eb bc                	jmp    800bb5 <strtol+0x72>
  800bf9:	89 d8                	mov    %ebx,%eax
  800bfb:	eb 02                	jmp    800bff <strtol+0xbc>
  800bfd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c03:	74 05                	je     800c0a <strtol+0xc7>
		*endptr = (char *) s;
  800c05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c08:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800c0a:	f7 d8                	neg    %eax
  800c0c:	85 ff                	test   %edi,%edi
  800c0e:	0f 44 c3             	cmove  %ebx,%eax
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	89 c3                	mov    %eax,%ebx
  800c29:	89 c7                	mov    %eax,%edi
  800c2b:	89 c6                	mov    %eax,%esi
  800c2d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c44:	89 d1                	mov    %edx,%ecx
  800c46:	89 d3                	mov    %edx,%ebx
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c61:	b8 03 00 00 00       	mov    $0x3,%eax
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	89 cb                	mov    %ecx,%ebx
  800c6b:	89 cf                	mov    %ecx,%edi
  800c6d:	89 ce                	mov    %ecx,%esi
  800c6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 28                	jle    800c9d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c79:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c80:	00 
  800c81:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800c88:	00 
  800c89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c90:	00 
  800c91:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800c98:	e8 07 f5 ff ff       	call   8001a4 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9d:	83 c4 2c             	add    $0x2c,%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_yield>:

void
sys_yield(void)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cca:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd4:	89 d1                	mov    %edx,%ecx
  800cd6:	89 d3                	mov    %edx,%ebx
  800cd8:	89 d7                	mov    %edx,%edi
  800cda:	89 d6                	mov    %edx,%esi
  800cdc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cec:	be 00 00 00 00       	mov    $0x0,%esi
  800cf1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cff:	89 f7                	mov    %esi,%edi
  800d01:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 28                	jle    800d2f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d12:	00 
  800d13:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800d1a:	00 
  800d1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d22:	00 
  800d23:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800d2a:	e8 75 f4 ff ff       	call   8001a4 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2f:	83 c4 2c             	add    $0x2c,%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d40:	b8 05 00 00 00       	mov    $0x5,%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d51:	8b 75 18             	mov    0x18(%ebp),%esi
  800d54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d56:	85 c0                	test   %eax,%eax
  800d58:	7e 28                	jle    800d82 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d65:	00 
  800d66:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800d6d:	00 
  800d6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d75:	00 
  800d76:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800d7d:	e8 22 f4 ff ff       	call   8001a4 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d82:	83 c4 2c             	add    $0x2c,%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 28                	jle    800dd5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800db8:	00 
  800db9:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc8:	00 
  800dc9:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800dd0:	e8 cf f3 ff ff       	call   8001a4 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd5:	83 c4 2c             	add    $0x2c,%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	b8 08 00 00 00       	mov    $0x8,%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	8b 55 08             	mov    0x8(%ebp),%edx
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7e 28                	jle    800e28 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e04:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e0b:	00 
  800e0c:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800e13:	00 
  800e14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1b:	00 
  800e1c:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800e23:	e8 7c f3 ff ff       	call   8001a4 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e28:	83 c4 2c             	add    $0x2c,%esp
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800e39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 df                	mov    %ebx,%edi
  800e4b:	89 de                	mov    %ebx,%esi
  800e4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7e 28                	jle    800e7b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e57:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6e:	00 
  800e6f:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800e76:	e8 29 f3 ff ff       	call   8001a4 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7b:	83 c4 2c             	add    $0x2c,%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e89:	be 00 00 00 00       	mov    $0x0,%esi
  800e8e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e96:	8b 55 08             	mov    0x8(%ebp),%edx
  800e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800eaf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	89 cb                	mov    %ecx,%ebx
  800ebe:	89 cf                	mov    %ecx,%edi
  800ec0:	89 ce                	mov    %ecx,%esi
  800ec2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	7e 28                	jle    800ef0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecc:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ed3:	00 
  800ed4:	c7 44 24 08 64 19 80 	movl   $0x801964,0x8(%esp)
  800edb:	00 
  800edc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee3:	00 
  800ee4:	c7 04 24 81 19 80 00 	movl   $0x801981,(%esp)
  800eeb:	e8 b4 f2 ff ff       	call   8001a4 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef0:	83 c4 2c             	add    $0x2c,%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	56                   	push   %esi
  800efc:	53                   	push   %ebx
  800efd:	83 ec 20             	sub    $0x20,%esp
  800f00:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f03:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR))
  800f05:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f09:	75 1c                	jne    800f27 <pgfault+0x2f>
		panic("pgfault: not writable\n");
  800f0b:	c7 44 24 08 8f 19 80 	movl   $0x80198f,0x8(%esp)
  800f12:	00 
  800f13:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f1a:	00 
  800f1b:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  800f22:	e8 7d f2 ff ff       	call   8001a4 <_panic>
	
	if (!(uvpt[ (uintptr_t)addr >> PTXSHIFT] & PTE_COW))
  800f27:	89 f0                	mov    %esi,%eax
  800f29:	c1 e8 0c             	shr    $0xc,%eax
  800f2c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f33:	f6 c4 08             	test   $0x8,%ah
  800f36:	75 1c                	jne    800f54 <pgfault+0x5c>
		panic("pgfault: not COW page\n");
  800f38:	c7 44 24 08 b1 19 80 	movl   $0x8019b1,0x8(%esp)
  800f3f:	00 
  800f40:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800f47:	00 
  800f48:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  800f4f:	e8 50 f2 ff ff       	call   8001a4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800f54:	e8 4c fd ff ff       	call   800ca5 <sys_getenvid>
  800f59:	89 c3                	mov    %eax,%ebx

	if ((r = sys_page_alloc(envid, PFTEMP, (PTE_U|PTE_W))) < 0)
  800f5b:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800f62:	00 
  800f63:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f6a:	00 
  800f6b:	89 04 24             	mov    %eax,(%esp)
  800f6e:	e8 70 fd ff ff       	call   800ce3 <sys_page_alloc>
  800f73:	85 c0                	test   %eax,%eax
  800f75:	79 20                	jns    800f97 <pgfault+0x9f>
		panic("pgfault: sys_page_alloc() failed %e", r);
  800f77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7b:	c7 44 24 08 ec 19 80 	movl   $0x8019ec,0x8(%esp)
  800f82:	00 
  800f83:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800f8a:	00 
  800f8b:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  800f92:	e8 0d f2 ff ff       	call   8001a4 <_panic>

	//memcpy( (void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE );
	memcpy( (void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE );
  800f97:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  800f9d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fa4:	00 
  800fa5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fb0:	e8 17 fb ff ff       	call   800acc <memcpy>

	if ((r = sys_page_map(envid, (void *)PFTEMP, envid, (void *)ROUNDDOWN(addr, PGSIZE), (PTE_U|PTE_W))) < 0)
  800fb5:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  800fbc:	00 
  800fbd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fc1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fc5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fcc:	00 
  800fcd:	89 1c 24             	mov    %ebx,(%esp)
  800fd0:	e8 62 fd ff ff       	call   800d37 <sys_page_map>
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 20                	jns    800ff9 <pgfault+0x101>
		panic("pgfault: sys_page_map() failed %e", r);
  800fd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fdd:	c7 44 24 08 10 1a 80 	movl   $0x801a10,0x8(%esp)
  800fe4:	00 
  800fe5:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800fec:	00 
  800fed:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  800ff4:	e8 ab f1 ff ff       	call   8001a4 <_panic>
	
	if ((r = sys_page_unmap(envid, (void *)PFTEMP)) < 0)
  800ff9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801000:	00 
  801001:	89 1c 24             	mov    %ebx,(%esp)
  801004:	e8 81 fd ff ff       	call   800d8a <sys_page_unmap>
  801009:	85 c0                	test   %eax,%eax
  80100b:	79 20                	jns    80102d <pgfault+0x135>
		panic("pgfault: sys_page_unmap() failed %e", r);
  80100d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801011:	c7 44 24 08 34 1a 80 	movl   $0x801a34,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  801028:	e8 77 f1 ff ff       	call   8001a4 <_panic>


	//panic("pgfault not implemented");
}
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
  80103a:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	envid_t envid;
	uint8_t *addr;
	int r;

	set_pgfault_handler(pgfault);
  80103d:	c7 04 24 f8 0e 80 00 	movl   $0x800ef8,(%esp)
  801044:	e8 22 03 00 00       	call   80136b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801049:	b8 07 00 00 00       	mov    $0x7,%eax
  80104e:	cd 30                	int    $0x30
  801050:	89 c7                	mov    %eax,%edi
  801052:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid = sys_exofork();

	extern volatile pde_t uvpd[];
	extern volatile pte_t uvpt[];

	if (envid < 0)
  801055:	85 c0                	test   %eax,%eax
  801057:	0f 88 d3 01 00 00    	js     801230 <fork+0x1fc>
		return envid;

	if (envid == 0)
  80105d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801062:	85 c0                	test   %eax,%eax
  801064:	75 21                	jne    801087 <fork+0x53>
	{
		envid = sys_getenvid();
  801066:	e8 3a fc ff ff       	call   800ca5 <sys_getenvid>

		thisenv = &envs[ENVX(envid)];
  80106b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801078:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
  801082:	e9 ad 01 00 00       	jmp    801234 <fork+0x200>
	}
	
	for ( uintptr_t va = 0; va < UTOP; )
	{
		if ((uvpd[va >> PDXSHIFT] & PTE_P) == 0)
  801087:	89 d8                	mov    %ebx,%eax
  801089:	c1 e8 16             	shr    $0x16,%eax
  80108c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801093:	a8 01                	test   $0x1,%al
  801095:	75 0b                	jne    8010a2 <fork+0x6e>
		{
			va += NPTENTRIES * PGSIZE;
  801097:	81 c3 00 00 40 00    	add    $0x400000,%ebx
			continue;
  80109d:	e9 22 01 00 00       	jmp    8011c4 <fork+0x190>
		}
		
		if ((uvpt[va >> PTXSHIFT] & PTE_P) == 0)
  8010a2:	89 d8                	mov    %ebx,%eax
  8010a4:	c1 e8 0c             	shr    $0xc,%eax
  8010a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ae:	a8 01                	test   $0x1,%al
  8010b0:	75 0b                	jne    8010bd <fork+0x89>
		{
			va += PGSIZE;
  8010b2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
			continue;
  8010b8:	e9 07 01 00 00       	jmp    8011c4 <fork+0x190>
		}
		
		if (va == (UXSTACKTOP - PGSIZE))
  8010bd:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010c3:	0f 84 07 01 00 00    	je     8011d0 <fork+0x19c>
		{
			va += PGSIZE;
			continue;
		}

		if ((r = duppage(envid, (unsigned) (va/PGSIZE))) < 0)
  8010c9:	89 d8                	mov    %ebx,%eax
  8010cb:	c1 e8 0c             	shr    $0xc,%eax
  8010ce:	89 c6                	mov    %eax,%esi
	envid_t p_envid = sys_getenvid();
  8010d0:	e8 d0 fb ff ff       	call   800ca5 <sys_getenvid>
  8010d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	intptr_t va = (intptr_t)(pn * PGSIZE);
  8010d8:	89 f0                	mov    %esi,%eax
  8010da:	c1 e6 0c             	shl    $0xc,%esi
	if ( (uvpt[pn]) & (PTE_COW | PTE_W))
  8010dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e4:	a9 02 08 00 00       	test   $0x802,%eax
  8010e9:	0f 84 89 00 00 00    	je     801178 <fork+0x144>
		if ( (r = sys_page_map(p_envid , (void *)va, envid, (void *)va, (PTE_COW | PTE_U))) < 0 )
  8010ef:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  8010f6:	00 
  8010f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801102:	89 74 24 04          	mov    %esi,0x4(%esp)
  801106:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801109:	89 04 24             	mov    %eax,(%esp)
  80110c:	e8 26 fc ff ff       	call   800d37 <sys_page_map>
  801111:	85 c0                	test   %eax,%eax
  801113:	79 20                	jns    801135 <fork+0x101>
			panic("duppage: %e", r);
  801115:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801119:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  801120:	00 
  801121:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801128:	00 
  801129:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  801130:	e8 6f f0 ff ff       	call   8001a4 <_panic>
		if ( (r = sys_page_map(p_envid , (void *)va, p_envid, (void *)va,  (PTE_COW | PTE_U) )) < 0 )
  801135:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  80113c:	00 
  80113d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801144:	89 44 24 08          	mov    %eax,0x8(%esp)
  801148:	89 74 24 04          	mov    %esi,0x4(%esp)
  80114c:	89 04 24             	mov    %eax,(%esp)
  80114f:	e8 e3 fb ff ff       	call   800d37 <sys_page_map>
  801154:	85 c0                	test   %eax,%eax
  801156:	79 66                	jns    8011be <fork+0x18a>
			panic("duppage: %e", r);
  801158:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80115c:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  801163:	00 
  801164:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  80116b:	00 
  80116c:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  801173:	e8 2c f0 ff ff       	call   8001a4 <_panic>
		if ( (r = sys_page_map(p_envid, (void *)va, envid, (void *)va, PTE_U)) < 0 )
  801178:	c7 44 24 10 04 00 00 	movl   $0x4,0x10(%esp)
  80117f:	00 
  801180:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801184:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801187:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80118f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801192:	89 04 24             	mov    %eax,(%esp)
  801195:	e8 9d fb ff ff       	call   800d37 <sys_page_map>
  80119a:	85 c0                	test   %eax,%eax
  80119c:	79 20                	jns    8011be <fork+0x18a>
			panic("duppage: %e", r);
  80119e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a2:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  8011a9:	00 
  8011aa:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8011b1:	00 
  8011b2:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  8011b9:	e8 e6 ef ff ff       	call   8001a4 <_panic>
			return r;

		va += PGSIZE;
  8011be:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for ( uintptr_t va = 0; va < UTOP; )
  8011c4:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8011ca:	0f 86 b7 fe ff ff    	jbe    801087 <fork+0x53>
	}

	if ( (r = sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), (PTE_U | PTE_W))) < 0)
  8011d0:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8011d7:	00 
  8011d8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011df:	ee 
  8011e0:	89 3c 24             	mov    %edi,(%esp)
  8011e3:	e8 fb fa ff ff       	call   800ce3 <sys_page_alloc>
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 48                	js     801234 <fork+0x200>
		return r;

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011ec:	c7 44 24 04 f8 13 80 	movl   $0x8013f8,0x4(%esp)
  8011f3:	00 
  8011f4:	89 3c 24             	mov    %edi,(%esp)
  8011f7:	e8 34 fc ff ff       	call   800e30 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011fc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801203:	00 
  801204:	89 3c 24             	mov    %edi,(%esp)
  801207:	e8 d1 fb ff ff       	call   800ddd <sys_env_set_status>
  80120c:	85 c0                	test   %eax,%eax
  80120e:	79 22                	jns    801232 <fork+0x1fe>
		panic("fork: sys_env_set_status() failed %e", r);
  801210:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801214:	c7 44 24 08 58 1a 80 	movl   $0x801a58,0x8(%esp)
  80121b:	00 
  80121c:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  801223:	00 
  801224:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  80122b:	e8 74 ef ff ff       	call   8001a4 <_panic>
  801230:	eb 02                	jmp    801234 <fork+0x200>

	//panic("fork not implemented");
	return envid;
  801232:	89 f8                	mov    %edi,%eax
}
  801234:	83 c4 2c             	add    $0x2c,%esp
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5f                   	pop    %edi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <sfork>:

// Challenge!
int
sfork(void)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801242:	c7 44 24 08 d4 19 80 	movl   $0x8019d4,0x8(%esp)
  801249:	00 
  80124a:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  801251:	00 
  801252:	c7 04 24 a6 19 80 00 	movl   $0x8019a6,(%esp)
  801259:	e8 46 ef ff ff       	call   8001a4 <_panic>
  80125e:	66 90                	xchg   %ax,%ax

00801260 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 10             	sub    $0x10,%esp
  801268:	8b 75 08             	mov    0x8(%ebp),%esi
  80126b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80126e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *dstva = (void *)(-1);
	int r;

	if (pg)
  801271:	85 c0                	test   %eax,%eax
	void *dstva = (void *)(-1);
  801273:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801278:	0f 44 c2             	cmove  %edx,%eax
		dstva = pg;

	if ((r = sys_ipc_recv(dstva)) < 0)
  80127b:	89 04 24             	mov    %eax,(%esp)
  80127e:	e8 23 fc ff ff       	call   800ea6 <sys_ipc_recv>
  801283:	85 c0                	test   %eax,%eax
  801285:	79 16                	jns    80129d <ipc_recv+0x3d>
	{
		if (from_env_store)
  801287:	85 f6                	test   %esi,%esi
  801289:	74 06                	je     801291 <ipc_recv+0x31>
			*from_env_store = 0;
  80128b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		
		if (perm_store)
  801291:	85 db                	test   %ebx,%ebx
  801293:	74 2c                	je     8012c1 <ipc_recv+0x61>
			*perm_store = 0;
  801295:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80129b:	eb 24                	jmp    8012c1 <ipc_recv+0x61>
		
		return r;
	}

	if (from_env_store)
  80129d:	85 f6                	test   %esi,%esi
  80129f:	74 0a                	je     8012ab <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8012a1:	a1 04 20 80 00       	mov    0x802004,%eax
  8012a6:	8b 40 74             	mov    0x74(%eax),%eax
  8012a9:	89 06                	mov    %eax,(%esi)
	
	if (perm_store)
  8012ab:	85 db                	test   %ebx,%ebx
  8012ad:	74 0a                	je     8012b9 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8012af:	a1 04 20 80 00       	mov    0x802004,%eax
  8012b4:	8b 40 78             	mov    0x78(%eax),%eax
  8012b7:	89 03                	mov    %eax,(%ebx)

	//panic("ipc_recv not implemented");
	return (thisenv->env_ipc_value);
  8012b9:	a1 04 20 80 00       	mov    0x802004,%eax
  8012be:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	57                   	push   %edi
  8012cc:	56                   	push   %esi
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 1c             	sub    $0x1c,%esp
  8012d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *srcva = (void *)(-1);
	int r;

	if (pg)
  8012da:	85 db                	test   %ebx,%ebx
	void *srcva = (void *)(-1);
  8012dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8012e1:	0f 44 d8             	cmove  %eax,%ebx

	//cprintf("srcva: %d\n",srcva);
	
	for(;;)
	{
		r = sys_ipc_try_send(to_env, val, srcva, perm);
  8012e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012f3:	89 3c 24             	mov    %edi,(%esp)
  8012f6:	e8 88 fb ff ff       	call   800e83 <sys_ipc_try_send>

		if (r == 0)
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	74 2c                	je     80132b <ipc_send+0x63>
			break;
		
		if (r == -E_IPC_NOT_RECV)
  8012ff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801302:	75 07                	jne    80130b <ipc_send+0x43>
		{
			sys_yield();
  801304:	e8 bb f9 ff ff       	call   800cc4 <sys_yield>
			continue;
		}

		panic("ipc_send: %e", r);
	}
  801309:	eb d9                	jmp    8012e4 <ipc_send+0x1c>
		panic("ipc_send: %e", r);
  80130b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130f:	c7 44 24 08 7d 1a 80 	movl   $0x801a7d,0x8(%esp)
  801316:	00 
  801317:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  80131e:	00 
  80131f:	c7 04 24 8a 1a 80 00 	movl   $0x801a8a,(%esp)
  801326:	e8 79 ee ff ff       	call   8001a4 <_panic>
	
	//panic("ipc_send not implemented");
}
  80132b:	83 c4 1c             	add    $0x1c,%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5e                   	pop    %esi
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801339:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80133e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801341:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801347:	8b 52 50             	mov    0x50(%edx),%edx
  80134a:	39 ca                	cmp    %ecx,%edx
  80134c:	75 0d                	jne    80135b <ipc_find_env+0x28>
			return envs[i].env_id;
  80134e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801351:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801356:	8b 40 40             	mov    0x40(%eax),%eax
  801359:	eb 0e                	jmp    801369 <ipc_find_env+0x36>
	for (i = 0; i < NENV; i++)
  80135b:	83 c0 01             	add    $0x1,%eax
  80135e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801363:	75 d9                	jne    80133e <ipc_find_env+0xb>
	return 0;
  801365:	66 b8 00 00          	mov    $0x0,%ax
}
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	53                   	push   %ebx
  80136f:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  801372:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801379:	75 6f                	jne    8013ea <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80137b:	e8 25 f9 ff ff       	call   800ca5 <sys_getenvid>
  801380:	89 c3                	mov    %eax,%ebx
		
		if ( (r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), (PTE_U | PTE_W | PTE_P))) < 0 )
  801382:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801389:	00 
  80138a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801391:	ee 
  801392:	89 04 24             	mov    %eax,(%esp)
  801395:	e8 49 f9 ff ff       	call   800ce3 <sys_page_alloc>
  80139a:	85 c0                	test   %eax,%eax
  80139c:	79 1c                	jns    8013ba <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc() failed\n");
  80139e:	c7 44 24 08 94 1a 80 	movl   $0x801a94,0x8(%esp)
  8013a5:	00 
  8013a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013ad:	00 
  8013ae:	c7 04 24 f8 1a 80 00 	movl   $0x801af8,(%esp)
  8013b5:	e8 ea ed ff ff       	call   8001a4 <_panic>
		
		if ( (r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0 )
  8013ba:	c7 44 24 04 f8 13 80 	movl   $0x8013f8,0x4(%esp)
  8013c1:	00 
  8013c2:	89 1c 24             	mov    %ebx,(%esp)
  8013c5:	e8 66 fa ff ff       	call   800e30 <sys_env_set_pgfault_upcall>
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	79 1c                	jns    8013ea <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  8013ce:	c7 44 24 08 c4 1a 80 	movl   $0x801ac4,0x8(%esp)
  8013d5:	00 
  8013d6:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8013dd:	00 
  8013de:	c7 04 24 f8 1a 80 00 	movl   $0x801af8,(%esp)
  8013e5:	e8 ba ed ff ff       	call   8001a4 <_panic>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ed:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8013f2:	83 c4 14             	add    $0x14,%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    

008013f8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013f8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013f9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8013fe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801400:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	add $8, %esp
  801403:	83 c4 08             	add    $0x8,%esp
	mov 32(%esp), %ebx
  801406:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	mov 40(%esp), %eax
  80140a:	8b 44 24 28          	mov    0x28(%esp),%eax
	sub $4, %eax
  80140e:	83 e8 04             	sub    $0x4,%eax
	mov %ebx, (%eax)
  801411:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popa
  801413:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  801414:	83 c4 04             	add    $0x4,%esp
	popf
  801417:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop	%esp
  801418:	5c                   	pop    %esp
	

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp
  801419:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  80141d:	c3                   	ret    
  80141e:	66 90                	xchg   %ax,%ax

00801420 <__udivdi3>:
  801420:	55                   	push   %ebp
  801421:	57                   	push   %edi
  801422:	56                   	push   %esi
  801423:	83 ec 0c             	sub    $0xc,%esp
  801426:	8b 44 24 28          	mov    0x28(%esp),%eax
  80142a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80142e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801432:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801436:	85 c0                	test   %eax,%eax
  801438:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80143c:	89 ea                	mov    %ebp,%edx
  80143e:	89 0c 24             	mov    %ecx,(%esp)
  801441:	75 2d                	jne    801470 <__udivdi3+0x50>
  801443:	39 e9                	cmp    %ebp,%ecx
  801445:	77 61                	ja     8014a8 <__udivdi3+0x88>
  801447:	85 c9                	test   %ecx,%ecx
  801449:	89 ce                	mov    %ecx,%esi
  80144b:	75 0b                	jne    801458 <__udivdi3+0x38>
  80144d:	b8 01 00 00 00       	mov    $0x1,%eax
  801452:	31 d2                	xor    %edx,%edx
  801454:	f7 f1                	div    %ecx
  801456:	89 c6                	mov    %eax,%esi
  801458:	31 d2                	xor    %edx,%edx
  80145a:	89 e8                	mov    %ebp,%eax
  80145c:	f7 f6                	div    %esi
  80145e:	89 c5                	mov    %eax,%ebp
  801460:	89 f8                	mov    %edi,%eax
  801462:	f7 f6                	div    %esi
  801464:	89 ea                	mov    %ebp,%edx
  801466:	83 c4 0c             	add    $0xc,%esp
  801469:	5e                   	pop    %esi
  80146a:	5f                   	pop    %edi
  80146b:	5d                   	pop    %ebp
  80146c:	c3                   	ret    
  80146d:	8d 76 00             	lea    0x0(%esi),%esi
  801470:	39 e8                	cmp    %ebp,%eax
  801472:	77 24                	ja     801498 <__udivdi3+0x78>
  801474:	0f bd e8             	bsr    %eax,%ebp
  801477:	83 f5 1f             	xor    $0x1f,%ebp
  80147a:	75 3c                	jne    8014b8 <__udivdi3+0x98>
  80147c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801480:	39 34 24             	cmp    %esi,(%esp)
  801483:	0f 86 9f 00 00 00    	jbe    801528 <__udivdi3+0x108>
  801489:	39 d0                	cmp    %edx,%eax
  80148b:	0f 82 97 00 00 00    	jb     801528 <__udivdi3+0x108>
  801491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801498:	31 d2                	xor    %edx,%edx
  80149a:	31 c0                	xor    %eax,%eax
  80149c:	83 c4 0c             	add    $0xc,%esp
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    
  8014a3:	90                   	nop
  8014a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a8:	89 f8                	mov    %edi,%eax
  8014aa:	f7 f1                	div    %ecx
  8014ac:	31 d2                	xor    %edx,%edx
  8014ae:	83 c4 0c             	add    $0xc,%esp
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    
  8014b5:	8d 76 00             	lea    0x0(%esi),%esi
  8014b8:	89 e9                	mov    %ebp,%ecx
  8014ba:	8b 3c 24             	mov    (%esp),%edi
  8014bd:	d3 e0                	shl    %cl,%eax
  8014bf:	89 c6                	mov    %eax,%esi
  8014c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8014c6:	29 e8                	sub    %ebp,%eax
  8014c8:	89 c1                	mov    %eax,%ecx
  8014ca:	d3 ef                	shr    %cl,%edi
  8014cc:	89 e9                	mov    %ebp,%ecx
  8014ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014d2:	8b 3c 24             	mov    (%esp),%edi
  8014d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8014d9:	89 d6                	mov    %edx,%esi
  8014db:	d3 e7                	shl    %cl,%edi
  8014dd:	89 c1                	mov    %eax,%ecx
  8014df:	89 3c 24             	mov    %edi,(%esp)
  8014e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014e6:	d3 ee                	shr    %cl,%esi
  8014e8:	89 e9                	mov    %ebp,%ecx
  8014ea:	d3 e2                	shl    %cl,%edx
  8014ec:	89 c1                	mov    %eax,%ecx
  8014ee:	d3 ef                	shr    %cl,%edi
  8014f0:	09 d7                	or     %edx,%edi
  8014f2:	89 f2                	mov    %esi,%edx
  8014f4:	89 f8                	mov    %edi,%eax
  8014f6:	f7 74 24 08          	divl   0x8(%esp)
  8014fa:	89 d6                	mov    %edx,%esi
  8014fc:	89 c7                	mov    %eax,%edi
  8014fe:	f7 24 24             	mull   (%esp)
  801501:	39 d6                	cmp    %edx,%esi
  801503:	89 14 24             	mov    %edx,(%esp)
  801506:	72 30                	jb     801538 <__udivdi3+0x118>
  801508:	8b 54 24 04          	mov    0x4(%esp),%edx
  80150c:	89 e9                	mov    %ebp,%ecx
  80150e:	d3 e2                	shl    %cl,%edx
  801510:	39 c2                	cmp    %eax,%edx
  801512:	73 05                	jae    801519 <__udivdi3+0xf9>
  801514:	3b 34 24             	cmp    (%esp),%esi
  801517:	74 1f                	je     801538 <__udivdi3+0x118>
  801519:	89 f8                	mov    %edi,%eax
  80151b:	31 d2                	xor    %edx,%edx
  80151d:	e9 7a ff ff ff       	jmp    80149c <__udivdi3+0x7c>
  801522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801528:	31 d2                	xor    %edx,%edx
  80152a:	b8 01 00 00 00       	mov    $0x1,%eax
  80152f:	e9 68 ff ff ff       	jmp    80149c <__udivdi3+0x7c>
  801534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801538:	8d 47 ff             	lea    -0x1(%edi),%eax
  80153b:	31 d2                	xor    %edx,%edx
  80153d:	83 c4 0c             	add    $0xc,%esp
  801540:	5e                   	pop    %esi
  801541:	5f                   	pop    %edi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    
  801544:	66 90                	xchg   %ax,%ax
  801546:	66 90                	xchg   %ax,%ax
  801548:	66 90                	xchg   %ax,%ax
  80154a:	66 90                	xchg   %ax,%ax
  80154c:	66 90                	xchg   %ax,%ax
  80154e:	66 90                	xchg   %ax,%ax

00801550 <__umoddi3>:
  801550:	55                   	push   %ebp
  801551:	57                   	push   %edi
  801552:	56                   	push   %esi
  801553:	83 ec 14             	sub    $0x14,%esp
  801556:	8b 44 24 28          	mov    0x28(%esp),%eax
  80155a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80155e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801562:	89 c7                	mov    %eax,%edi
  801564:	89 44 24 04          	mov    %eax,0x4(%esp)
  801568:	8b 44 24 30          	mov    0x30(%esp),%eax
  80156c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801570:	89 34 24             	mov    %esi,(%esp)
  801573:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801577:	85 c0                	test   %eax,%eax
  801579:	89 c2                	mov    %eax,%edx
  80157b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80157f:	75 17                	jne    801598 <__umoddi3+0x48>
  801581:	39 fe                	cmp    %edi,%esi
  801583:	76 4b                	jbe    8015d0 <__umoddi3+0x80>
  801585:	89 c8                	mov    %ecx,%eax
  801587:	89 fa                	mov    %edi,%edx
  801589:	f7 f6                	div    %esi
  80158b:	89 d0                	mov    %edx,%eax
  80158d:	31 d2                	xor    %edx,%edx
  80158f:	83 c4 14             	add    $0x14,%esp
  801592:	5e                   	pop    %esi
  801593:	5f                   	pop    %edi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    
  801596:	66 90                	xchg   %ax,%ax
  801598:	39 f8                	cmp    %edi,%eax
  80159a:	77 54                	ja     8015f0 <__umoddi3+0xa0>
  80159c:	0f bd e8             	bsr    %eax,%ebp
  80159f:	83 f5 1f             	xor    $0x1f,%ebp
  8015a2:	75 5c                	jne    801600 <__umoddi3+0xb0>
  8015a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8015a8:	39 3c 24             	cmp    %edi,(%esp)
  8015ab:	0f 87 e7 00 00 00    	ja     801698 <__umoddi3+0x148>
  8015b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015b5:	29 f1                	sub    %esi,%ecx
  8015b7:	19 c7                	sbb    %eax,%edi
  8015b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015c9:	83 c4 14             	add    $0x14,%esp
  8015cc:	5e                   	pop    %esi
  8015cd:	5f                   	pop    %edi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    
  8015d0:	85 f6                	test   %esi,%esi
  8015d2:	89 f5                	mov    %esi,%ebp
  8015d4:	75 0b                	jne    8015e1 <__umoddi3+0x91>
  8015d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015db:	31 d2                	xor    %edx,%edx
  8015dd:	f7 f6                	div    %esi
  8015df:	89 c5                	mov    %eax,%ebp
  8015e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8015e5:	31 d2                	xor    %edx,%edx
  8015e7:	f7 f5                	div    %ebp
  8015e9:	89 c8                	mov    %ecx,%eax
  8015eb:	f7 f5                	div    %ebp
  8015ed:	eb 9c                	jmp    80158b <__umoddi3+0x3b>
  8015ef:	90                   	nop
  8015f0:	89 c8                	mov    %ecx,%eax
  8015f2:	89 fa                	mov    %edi,%edx
  8015f4:	83 c4 14             	add    $0x14,%esp
  8015f7:	5e                   	pop    %esi
  8015f8:	5f                   	pop    %edi
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    
  8015fb:	90                   	nop
  8015fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801600:	8b 04 24             	mov    (%esp),%eax
  801603:	be 20 00 00 00       	mov    $0x20,%esi
  801608:	89 e9                	mov    %ebp,%ecx
  80160a:	29 ee                	sub    %ebp,%esi
  80160c:	d3 e2                	shl    %cl,%edx
  80160e:	89 f1                	mov    %esi,%ecx
  801610:	d3 e8                	shr    %cl,%eax
  801612:	89 e9                	mov    %ebp,%ecx
  801614:	89 44 24 04          	mov    %eax,0x4(%esp)
  801618:	8b 04 24             	mov    (%esp),%eax
  80161b:	09 54 24 04          	or     %edx,0x4(%esp)
  80161f:	89 fa                	mov    %edi,%edx
  801621:	d3 e0                	shl    %cl,%eax
  801623:	89 f1                	mov    %esi,%ecx
  801625:	89 44 24 08          	mov    %eax,0x8(%esp)
  801629:	8b 44 24 10          	mov    0x10(%esp),%eax
  80162d:	d3 ea                	shr    %cl,%edx
  80162f:	89 e9                	mov    %ebp,%ecx
  801631:	d3 e7                	shl    %cl,%edi
  801633:	89 f1                	mov    %esi,%ecx
  801635:	d3 e8                	shr    %cl,%eax
  801637:	89 e9                	mov    %ebp,%ecx
  801639:	09 f8                	or     %edi,%eax
  80163b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80163f:	f7 74 24 04          	divl   0x4(%esp)
  801643:	d3 e7                	shl    %cl,%edi
  801645:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801649:	89 d7                	mov    %edx,%edi
  80164b:	f7 64 24 08          	mull   0x8(%esp)
  80164f:	39 d7                	cmp    %edx,%edi
  801651:	89 c1                	mov    %eax,%ecx
  801653:	89 14 24             	mov    %edx,(%esp)
  801656:	72 2c                	jb     801684 <__umoddi3+0x134>
  801658:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80165c:	72 22                	jb     801680 <__umoddi3+0x130>
  80165e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801662:	29 c8                	sub    %ecx,%eax
  801664:	19 d7                	sbb    %edx,%edi
  801666:	89 e9                	mov    %ebp,%ecx
  801668:	89 fa                	mov    %edi,%edx
  80166a:	d3 e8                	shr    %cl,%eax
  80166c:	89 f1                	mov    %esi,%ecx
  80166e:	d3 e2                	shl    %cl,%edx
  801670:	89 e9                	mov    %ebp,%ecx
  801672:	d3 ef                	shr    %cl,%edi
  801674:	09 d0                	or     %edx,%eax
  801676:	89 fa                	mov    %edi,%edx
  801678:	83 c4 14             	add    $0x14,%esp
  80167b:	5e                   	pop    %esi
  80167c:	5f                   	pop    %edi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    
  80167f:	90                   	nop
  801680:	39 d7                	cmp    %edx,%edi
  801682:	75 da                	jne    80165e <__umoddi3+0x10e>
  801684:	8b 14 24             	mov    (%esp),%edx
  801687:	89 c1                	mov    %eax,%ecx
  801689:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80168d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801691:	eb cb                	jmp    80165e <__umoddi3+0x10e>
  801693:	90                   	nop
  801694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801698:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80169c:	0f 82 0f ff ff ff    	jb     8015b1 <__umoddi3+0x61>
  8016a2:	e9 1a ff ff ff       	jmp    8015c1 <__umoddi3+0x71>
