
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 8e 00 00 00       	call   8000bf <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 20 15 80 00 	movl   $0x801520,(%esp)
  80004e:	e8 6b 01 00 00       	call   8001be <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 fc 0e 00 00       	call   800f54 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 98 15 80 00 	movl   $0x801598,(%esp)
  800065:	e8 54 01 00 00       	call   8001be <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 48 15 80 00 	movl   $0x801548,(%esp)
  800073:	e8 46 01 00 00       	call   8001be <cprintf>
	sys_yield();
  800078:	e8 67 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80007d:	e8 62 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  800082:	e8 5d 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  800087:	e8 58 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 4f 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  800095:	e8 4a 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80009a:	e8 45 0b 00 00       	call   800be4 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 3f 0b 00 00       	call   800be4 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 70 15 80 00 	movl   $0x801570,(%esp)
  8000ac:	e8 0d 01 00 00       	call   8001be <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 ba 0a 00 00       	call   800b73 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 10             	sub    $0x10,%esp
  8000c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000cd:	e8 f3 0a 00 00       	call   800bc5 <sys_getenvid>
  8000d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000df:	a3 04 20 80 00       	mov    %eax,0x802004


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e4:	85 db                	test   %ebx,%ebx
  8000e6:	7e 07                	jle    8000ef <libmain+0x30>
		binaryname = argv[0];
  8000e8:	8b 06                	mov    (%esi),%eax
  8000ea:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000f3:	89 1c 24             	mov    %ebx,(%esp)
  8000f6:	e8 45 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000fb:	e8 07 00 00 00       	call   800107 <exit>
}
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80010d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800114:	e8 5a 0a 00 00       	call   800b73 <sys_env_destroy>
}
  800119:	c9                   	leave  
  80011a:	c3                   	ret    

0080011b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	53                   	push   %ebx
  80011f:	83 ec 14             	sub    $0x14,%esp
  800122:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800125:	8b 13                	mov    (%ebx),%edx
  800127:	8d 42 01             	lea    0x1(%edx),%eax
  80012a:	89 03                	mov    %eax,(%ebx)
  80012c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800133:	3d ff 00 00 00       	cmp    $0xff,%eax
  800138:	75 19                	jne    800153 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80013a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800141:	00 
  800142:	8d 43 08             	lea    0x8(%ebx),%eax
  800145:	89 04 24             	mov    %eax,(%esp)
  800148:	e8 e9 09 00 00       	call   800b36 <sys_cputs>
		b->idx = 0;
  80014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800153:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800157:	83 c4 14             	add    $0x14,%esp
  80015a:	5b                   	pop    %ebx
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    

0080015d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800166:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016d:	00 00 00 
	b.cnt = 0;
  800170:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800177:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	89 44 24 08          	mov    %eax,0x8(%esp)
  800188:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 1b 01 80 00 	movl   $0x80011b,(%esp)
  800199:	e8 b0 01 00 00       	call   80034e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 80 09 00 00       	call   800b36 <sys_cputs>

	return b.cnt;
}
  8001b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	e8 87 ff ff ff       	call   80015d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    
  8001d8:	66 90                	xchg   %ax,%ax
  8001da:	66 90                	xchg   %ax,%ax
  8001dc:	66 90                	xchg   %ax,%ax
  8001de:	66 90                	xchg   %ax,%ax

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 3c             	sub    $0x3c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d7                	mov    %edx,%edi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800202:	b9 00 00 00 00       	mov    $0x0,%ecx
  800207:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80020d:	39 d9                	cmp    %ebx,%ecx
  80020f:	72 05                	jb     800216 <printnum+0x36>
  800211:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800214:	77 69                	ja     80027f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800216:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800219:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80021d:	83 ee 01             	sub    $0x1,%esi
  800220:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800224:	89 44 24 08          	mov    %eax,0x8(%esp)
  800228:	8b 44 24 08          	mov    0x8(%esp),%eax
  80022c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800230:	89 c3                	mov    %eax,%ebx
  800232:	89 d6                	mov    %edx,%esi
  800234:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800237:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80023a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80023e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	e8 3c 10 00 00       	call   801290 <__udivdi3>
  800254:	89 d9                	mov    %ebx,%ecx
  800256:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	89 54 24 04          	mov    %edx,0x4(%esp)
  800265:	89 fa                	mov    %edi,%edx
  800267:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026a:	e8 71 ff ff ff       	call   8001e0 <printnum>
  80026f:	eb 1b                	jmp    80028c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800271:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800275:	8b 45 18             	mov    0x18(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff d3                	call   *%ebx
  80027d:	eb 03                	jmp    800282 <printnum+0xa2>
  80027f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800282:	83 ee 01             	sub    $0x1,%esi
  800285:	85 f6                	test   %esi,%esi
  800287:	7f e8                	jg     800271 <printnum+0x91>
  800289:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800290:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800294:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800297:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002af:	e8 0c 11 00 00       	call   8013c0 <__umoddi3>
  8002b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b8:	0f be 80 c0 15 80 00 	movsbl 0x8015c0(%eax),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c5:	ff d0                	call   *%eax
}
  8002c7:	83 c4 3c             	add    $0x3c,%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d2:	83 fa 01             	cmp    $0x1,%edx
  8002d5:	7e 0e                	jle    8002e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 02                	mov    (%edx),%eax
  8002e0:	8b 52 04             	mov    0x4(%edx),%edx
  8002e3:	eb 22                	jmp    800307 <getuint+0x38>
	else if (lflag)
  8002e5:	85 d2                	test   %edx,%edx
  8002e7:	74 10                	je     8002f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f7:	eb 0e                	jmp    800307 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 02                	mov    (%edx),%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800313:	8b 10                	mov    (%eax),%edx
  800315:	3b 50 04             	cmp    0x4(%eax),%edx
  800318:	73 0a                	jae    800324 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 45 08             	mov    0x8(%ebp),%eax
  800322:	88 02                	mov    %al,(%edx)
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <printfmt>:
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80032c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800333:	8b 45 10             	mov    0x10(%ebp),%eax
  800336:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800341:	8b 45 08             	mov    0x8(%ebp),%eax
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	e8 02 00 00 00       	call   80034e <vprintfmt>
}
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <vprintfmt>:
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	57                   	push   %edi
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
  800354:	83 ec 3c             	sub    $0x3c,%esp
  800357:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80035a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035d:	eb 14                	jmp    800373 <vprintfmt+0x25>
			if (ch == '\0'){
  80035f:	85 c0                	test   %eax,%eax
  800361:	0f 84 b3 03 00 00    	je     80071a <vprintfmt+0x3cc>
			putch(ch, putdat);
  800367:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800371:	89 f3                	mov    %esi,%ebx
  800373:	8d 73 01             	lea    0x1(%ebx),%esi
  800376:	0f b6 03             	movzbl (%ebx),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e1                	jne    80035f <vprintfmt+0x11>
  80037e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800382:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800389:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800390:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 1d                	jmp    8003bb <vprintfmt+0x6d>
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	89 de                	mov    %ebx,%esi
			padc = '-';
  8003a0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003a4:	eb 15                	jmp    8003bb <vprintfmt+0x6d>
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	89 de                	mov    %ebx,%esi
			padc = '0';
  8003a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003ac:	eb 0d                	jmp    8003bb <vprintfmt+0x6d>
				width = precision, precision = -1;
  8003ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003be:	0f b6 0e             	movzbl (%esi),%ecx
  8003c1:	0f b6 c1             	movzbl %cl,%eax
  8003c4:	83 e9 23             	sub    $0x23,%ecx
  8003c7:	80 f9 55             	cmp    $0x55,%cl
  8003ca:	0f 87 2a 03 00 00    	ja     8006fa <vprintfmt+0x3ac>
  8003d0:	0f b6 c9             	movzbl %cl,%ecx
  8003d3:	ff 24 8d 80 16 80 00 	jmp    *0x801680(,%ecx,4)
  8003da:	89 de                	mov    %ebx,%esi
  8003dc:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8003e1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003e4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003e8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003eb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003ee:	83 fb 09             	cmp    $0x9,%ebx
  8003f1:	77 36                	ja     800429 <vprintfmt+0xdb>
			for (precision = 0; ; ++fmt) {
  8003f3:	83 c6 01             	add    $0x1,%esi
			}
  8003f6:	eb e9                	jmp    8003e1 <vprintfmt+0x93>
			precision = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800401:	8b 00                	mov    (%eax),%eax
  800403:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800406:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800408:	eb 22                	jmp    80042c <vprintfmt+0xde>
  80040a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80040d:	85 c9                	test   %ecx,%ecx
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
  800414:	0f 49 c1             	cmovns %ecx,%eax
  800417:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	89 de                	mov    %ebx,%esi
  80041c:	eb 9d                	jmp    8003bb <vprintfmt+0x6d>
  80041e:	89 de                	mov    %ebx,%esi
			altflag = 1;
  800420:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800427:	eb 92                	jmp    8003bb <vprintfmt+0x6d>
  800429:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  80042c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800430:	79 89                	jns    8003bb <vprintfmt+0x6d>
  800432:	e9 77 ff ff ff       	jmp    8003ae <vprintfmt+0x60>
			lflag++;
  800437:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80043c:	e9 7a ff ff ff       	jmp    8003bb <vprintfmt+0x6d>
			putch(va_arg(ap, int), putdat);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 50 04             	lea    0x4(%eax),%edx
  800447:	89 55 14             	mov    %edx,0x14(%ebp)
  80044a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	ff 55 08             	call   *0x8(%ebp)
			break;
  800456:	e9 18 ff ff ff       	jmp    800373 <vprintfmt+0x25>
			err = va_arg(ap, int);
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 50 04             	lea    0x4(%eax),%edx
  800461:	89 55 14             	mov    %edx,0x14(%ebp)
  800464:	8b 00                	mov    (%eax),%eax
  800466:	99                   	cltd   
  800467:	31 d0                	xor    %edx,%eax
  800469:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046b:	83 f8 08             	cmp    $0x8,%eax
  80046e:	7f 0b                	jg     80047b <vprintfmt+0x12d>
  800470:	8b 14 85 e0 17 80 00 	mov    0x8017e0(,%eax,4),%edx
  800477:	85 d2                	test   %edx,%edx
  800479:	75 20                	jne    80049b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80047b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047f:	c7 44 24 08 d8 15 80 	movl   $0x8015d8,0x8(%esp)
  800486:	00 
  800487:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048b:	8b 45 08             	mov    0x8(%ebp),%eax
  80048e:	89 04 24             	mov    %eax,(%esp)
  800491:	e8 90 fe ff ff       	call   800326 <printfmt>
  800496:	e9 d8 fe ff ff       	jmp    800373 <vprintfmt+0x25>
				printfmt(putch, putdat, "%s", p);
  80049b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049f:	c7 44 24 08 e1 15 80 	movl   $0x8015e1,0x8(%esp)
  8004a6:	00 
  8004a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ae:	89 04 24             	mov    %eax,(%esp)
  8004b1:	e8 70 fe ff ff       	call   800326 <printfmt>
  8004b6:	e9 b8 fe ff ff       	jmp    800373 <vprintfmt+0x25>
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004cf:	85 f6                	test   %esi,%esi
  8004d1:	b8 d1 15 80 00       	mov    $0x8015d1,%eax
  8004d6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004dd:	0f 84 97 00 00 00    	je     80057a <vprintfmt+0x22c>
  8004e3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004e7:	0f 8e 9b 00 00 00    	jle    800588 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f1:	89 34 24             	mov    %esi,(%esp)
  8004f4:	e8 cf 02 00 00       	call   8007c8 <strnlen>
  8004f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004fc:	29 c2                	sub    %eax,%edx
  8004fe:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800501:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800505:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800508:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80050b:	8b 75 08             	mov    0x8(%ebp),%esi
  80050e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800511:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	eb 0f                	jmp    800524 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800515:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800519:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800521:	83 eb 01             	sub    $0x1,%ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f ed                	jg     800515 <vprintfmt+0x1c7>
  800528:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80052b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80052e:	85 d2                	test   %edx,%edx
  800530:	b8 00 00 00 00       	mov    $0x0,%eax
  800535:	0f 49 c2             	cmovns %edx,%eax
  800538:	29 c2                	sub    %eax,%edx
  80053a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80053d:	89 d7                	mov    %edx,%edi
  80053f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800542:	eb 50                	jmp    800594 <vprintfmt+0x246>
				if (altflag && (ch < ' ' || ch > '~'))
  800544:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800548:	74 1e                	je     800568 <vprintfmt+0x21a>
  80054a:	0f be d2             	movsbl %dl,%edx
  80054d:	83 ea 20             	sub    $0x20,%edx
  800550:	83 fa 5e             	cmp    $0x5e,%edx
  800553:	76 13                	jbe    800568 <vprintfmt+0x21a>
					putch('?', putdat);
  800555:	8b 45 0c             	mov    0xc(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
  800566:	eb 0d                	jmp    800575 <vprintfmt+0x227>
					putch(ch, putdat);
  800568:	8b 55 0c             	mov    0xc(%ebp),%edx
  80056b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80056f:	89 04 24             	mov    %eax,(%esp)
  800572:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800575:	83 ef 01             	sub    $0x1,%edi
  800578:	eb 1a                	jmp    800594 <vprintfmt+0x246>
  80057a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80057d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800580:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800583:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800586:	eb 0c                	jmp    800594 <vprintfmt+0x246>
  800588:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80058b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80058e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800591:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800594:	83 c6 01             	add    $0x1,%esi
  800597:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80059b:	0f be c2             	movsbl %dl,%eax
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	74 27                	je     8005c9 <vprintfmt+0x27b>
  8005a2:	85 db                	test   %ebx,%ebx
  8005a4:	78 9e                	js     800544 <vprintfmt+0x1f6>
  8005a6:	83 eb 01             	sub    $0x1,%ebx
  8005a9:	79 99                	jns    800544 <vprintfmt+0x1f6>
  8005ab:	89 f8                	mov    %edi,%eax
  8005ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b3:	89 c3                	mov    %eax,%ebx
  8005b5:	eb 1a                	jmp    8005d1 <vprintfmt+0x283>
				putch(' ', putdat);
  8005b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	eb 08                	jmp    8005d1 <vprintfmt+0x283>
  8005c9:	89 fb                	mov    %edi,%ebx
  8005cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005d1:	85 db                	test   %ebx,%ebx
  8005d3:	7f e2                	jg     8005b7 <vprintfmt+0x269>
  8005d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005db:	e9 93 fd ff ff       	jmp    800373 <vprintfmt+0x25>
	if (lflag >= 2)
  8005e0:	83 fa 01             	cmp    $0x1,%edx
  8005e3:	7e 16                	jle    8005fb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 50 08             	lea    0x8(%eax),%edx
  8005eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ee:	8b 50 04             	mov    0x4(%eax),%edx
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f9:	eb 32                	jmp    80062d <vprintfmt+0x2df>
	else if (lflag)
  8005fb:	85 d2                	test   %edx,%edx
  8005fd:	74 18                	je     800617 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 50 04             	lea    0x4(%eax),%edx
  800605:	89 55 14             	mov    %edx,0x14(%ebp)
  800608:	8b 30                	mov    (%eax),%esi
  80060a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80060d:	89 f0                	mov    %esi,%eax
  80060f:	c1 f8 1f             	sar    $0x1f,%eax
  800612:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800615:	eb 16                	jmp    80062d <vprintfmt+0x2df>
		return va_arg(*ap, int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 30                	mov    (%eax),%esi
  800622:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800625:	89 f0                	mov    %esi,%eax
  800627:	c1 f8 1f             	sar    $0x1f,%eax
  80062a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag);
  80062d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10;
  800633:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
  800638:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063c:	0f 89 80 00 00 00    	jns    8006c2 <vprintfmt+0x374>
				putch('-', putdat);
  800642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800646:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800650:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800653:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800656:	f7 d8                	neg    %eax
  800658:	83 d2 00             	adc    $0x0,%edx
  80065b:	f7 da                	neg    %edx
			base = 10;
  80065d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800662:	eb 5e                	jmp    8006c2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800664:	8d 45 14             	lea    0x14(%ebp),%eax
  800667:	e8 63 fc ff ff       	call   8002cf <getuint>
			base = 10;
  80066c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800671:	eb 4f                	jmp    8006c2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 54 fc ff ff       	call   8002cf <getuint>
      		base = 8;
  80067b:	b9 08 00 00 00       	mov    $0x8,%ecx
      		goto number;
  800680:	eb 40                	jmp    8006c2 <vprintfmt+0x374>
			putch('0', putdat);
  800682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800686:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80068d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800690:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800694:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80069b:	ff 55 08             	call   *0x8(%ebp)
				(uintptr_t) va_arg(ap, void *);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006a7:	8b 00                	mov    (%eax),%eax
  8006a9:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8006ae:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b3:	eb 0d                	jmp    8006c2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	e8 12 fc ff ff       	call   8002cf <getuint>
			base = 16;
  8006bd:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc);
  8006c2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8006c6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006ca:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006d5:	89 04 24             	mov    %eax,(%esp)
  8006d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006dc:	89 fa                	mov    %edi,%edx
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	e8 fa fa ff ff       	call   8001e0 <printnum>
			break;
  8006e6:	e9 88 fc ff ff       	jmp    800373 <vprintfmt+0x25>
			putch(ch, putdat);
  8006eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006f5:	e9 79 fc ff ff       	jmp    800373 <vprintfmt+0x25>
			putch('%', putdat);
  8006fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800705:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800708:	89 f3                	mov    %esi,%ebx
  80070a:	eb 03                	jmp    80070f <vprintfmt+0x3c1>
  80070c:	83 eb 01             	sub    $0x1,%ebx
  80070f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800713:	75 f7                	jne    80070c <vprintfmt+0x3be>
  800715:	e9 59 fc ff ff       	jmp    800373 <vprintfmt+0x25>
}
  80071a:	83 c4 3c             	add    $0x3c,%esp
  80071d:	5b                   	pop    %ebx
  80071e:	5e                   	pop    %esi
  80071f:	5f                   	pop    %edi
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 28             	sub    $0x28,%esp
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800731:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800735:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800738:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 30                	je     800773 <vsnprintf+0x51>
  800743:	85 d2                	test   %edx,%edx
  800745:	7e 2c                	jle    800773 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074e:	8b 45 10             	mov    0x10(%ebp),%eax
  800751:	89 44 24 08          	mov    %eax,0x8(%esp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075c:	c7 04 24 09 03 80 00 	movl   $0x800309,(%esp)
  800763:	e8 e6 fb ff ff       	call   80034e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800768:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800771:	eb 05                	jmp    800778 <vsnprintf+0x56>
		return -E_INVAL;
  800773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800783:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800787:	8b 45 10             	mov    0x10(%ebp),%eax
  80078a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800791:	89 44 24 04          	mov    %eax,0x4(%esp)
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	e8 82 ff ff ff       	call   800722 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    
  8007a2:	66 90                	xchg   %ax,%ax
  8007a4:	66 90                	xchg   %ax,%ax
  8007a6:	66 90                	xchg   %ax,%ax
  8007a8:	66 90                	xchg   %ax,%ax
  8007aa:	66 90                	xchg   %ax,%ax
  8007ac:	66 90                	xchg   %ax,%ax
  8007ae:	66 90                	xchg   %ax,%ax

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb 03                	jmp    8007c0 <strlen+0x10>
		n++;
  8007bd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c4:	75 f7                	jne    8007bd <strlen+0xd>
	return n;
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	eb 03                	jmp    8007db <strnlen+0x13>
		n++;
  8007d8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	39 d0                	cmp    %edx,%eax
  8007dd:	74 06                	je     8007e5 <strnlen+0x1d>
  8007df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e3:	75 f3                	jne    8007d8 <strnlen+0x10>
	return n;
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f1:	89 c2                	mov    %eax,%edx
  8007f3:	83 c2 01             	add    $0x1,%edx
  8007f6:	83 c1 01             	add    $0x1,%ecx
  8007f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800800:	84 db                	test   %bl,%bl
  800802:	75 ef                	jne    8007f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800804:	5b                   	pop    %ebx
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800811:	89 1c 24             	mov    %ebx,(%esp)
  800814:	e8 97 ff ff ff       	call   8007b0 <strlen>
	strcpy(dst + len, src);
  800819:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800820:	01 d8                	add    %ebx,%eax
  800822:	89 04 24             	mov    %eax,(%esp)
  800825:	e8 bd ff ff ff       	call   8007e7 <strcpy>
	return dst;
}
  80082a:	89 d8                	mov    %ebx,%eax
  80082c:	83 c4 08             	add    $0x8,%esp
  80082f:	5b                   	pop    %ebx
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	89 f3                	mov    %esi,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	89 f2                	mov    %esi,%edx
  800844:	eb 0f                	jmp    800855 <strncpy+0x23>
		*dst++ = *src;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084f:	80 39 01             	cmpb   $0x1,(%ecx)
  800852:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800855:	39 da                	cmp    %ebx,%edx
  800857:	75 ed                	jne    800846 <strncpy+0x14>
	}
	return ret;
}
  800859:	89 f0                	mov    %esi,%eax
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800873:	85 c9                	test   %ecx,%ecx
  800875:	75 0b                	jne    800882 <strlcpy+0x23>
  800877:	eb 1d                	jmp    800896 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	83 c2 01             	add    $0x1,%edx
  80087f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800882:	39 d8                	cmp    %ebx,%eax
  800884:	74 0b                	je     800891 <strlcpy+0x32>
  800886:	0f b6 0a             	movzbl (%edx),%ecx
  800889:	84 c9                	test   %cl,%cl
  80088b:	75 ec                	jne    800879 <strlcpy+0x1a>
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	eb 02                	jmp    800893 <strlcpy+0x34>
  800891:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800893:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
		p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
		n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 07                	jmp    80092e <strfind+0x13>
		if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 0a                	je     800935 <strfind+0x1a>
	for (; *s; s++)
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	0f b6 10             	movzbl (%eax),%edx
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
			break;
	return (char *) s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	89 04 24             	mov    %eax,(%esp)
  800a06:	e8 79 ff ff ff       	call   800984 <memmove>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 55 08             	mov    0x8(%ebp),%edx
  800a15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a18:	89 d6                	mov    %edx,%esi
  800a1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1d:	eb 1a                	jmp    800a39 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1f:	0f b6 02             	movzbl (%edx),%eax
  800a22:	0f b6 19             	movzbl (%ecx),%ebx
  800a25:	38 d8                	cmp    %bl,%al
  800a27:	74 0a                	je     800a33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 db             	movzbl %bl,%ebx
  800a2f:	29 d8                	sub    %ebx,%eax
  800a31:	eb 0f                	jmp    800a42 <memcmp+0x35>
		s1++, s2++;
  800a33:	83 c2 01             	add    $0x1,%edx
  800a36:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800a39:	39 f2                	cmp    %esi,%edx
  800a3b:	75 e2                	jne    800a1f <memcmp+0x12>
	}

	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a54:	eb 07                	jmp    800a5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	38 08                	cmp    %cl,(%eax)
  800a58:	74 07                	je     800a61 <memfind+0x1b>
	for (; s < ends; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	39 d0                	cmp    %edx,%eax
  800a5f:	72 f5                	jb     800a56 <memfind+0x10>
			break;
	return (void *) s;
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	eb 03                	jmp    800a74 <strtol+0x11>
		s++;
  800a71:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a74:	0f b6 0a             	movzbl (%edx),%ecx
  800a77:	80 f9 09             	cmp    $0x9,%cl
  800a7a:	74 f5                	je     800a71 <strtol+0xe>
  800a7c:	80 f9 20             	cmp    $0x20,%cl
  800a7f:	74 f0                	je     800a71 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a81:	80 f9 2b             	cmp    $0x2b,%cl
  800a84:	75 0a                	jne    800a90 <strtol+0x2d>
		s++;
  800a86:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a89:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8e:	eb 11                	jmp    800aa1 <strtol+0x3e>
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800a95:	80 f9 2d             	cmp    $0x2d,%cl
  800a98:	75 07                	jne    800aa1 <strtol+0x3e>
		s++, neg = 1;
  800a9a:	8d 52 01             	lea    0x1(%edx),%edx
  800a9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800aa6:	75 15                	jne    800abd <strtol+0x5a>
  800aa8:	80 3a 30             	cmpb   $0x30,(%edx)
  800aab:	75 10                	jne    800abd <strtol+0x5a>
  800aad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab1:	75 0a                	jne    800abd <strtol+0x5a>
		s += 2, base = 16;
  800ab3:	83 c2 02             	add    $0x2,%edx
  800ab6:	b8 10 00 00 00       	mov    $0x10,%eax
  800abb:	eb 10                	jmp    800acd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800abd:	85 c0                	test   %eax,%eax
  800abf:	75 0c                	jne    800acd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800ac3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ac6:	75 05                	jne    800acd <strtol+0x6a>
		s++, base = 8;
  800ac8:	83 c2 01             	add    $0x1,%edx
  800acb:	b0 08                	mov    $0x8,%al
		base = 10;
  800acd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ad2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad5:	0f b6 0a             	movzbl (%edx),%ecx
  800ad8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800adb:	89 f0                	mov    %esi,%eax
  800add:	3c 09                	cmp    $0x9,%al
  800adf:	77 08                	ja     800ae9 <strtol+0x86>
			dig = *s - '0';
  800ae1:	0f be c9             	movsbl %cl,%ecx
  800ae4:	83 e9 30             	sub    $0x30,%ecx
  800ae7:	eb 20                	jmp    800b09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ae9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800aec:	89 f0                	mov    %esi,%eax
  800aee:	3c 19                	cmp    $0x19,%al
  800af0:	77 08                	ja     800afa <strtol+0x97>
			dig = *s - 'a' + 10;
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 57             	sub    $0x57,%ecx
  800af8:	eb 0f                	jmp    800b09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800afd:	89 f0                	mov    %esi,%eax
  800aff:	3c 19                	cmp    $0x19,%al
  800b01:	77 16                	ja     800b19 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800b03:	0f be c9             	movsbl %cl,%ecx
  800b06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b0c:	7d 0f                	jge    800b1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800b0e:	83 c2 01             	add    $0x1,%edx
  800b11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800b15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800b17:	eb bc                	jmp    800ad5 <strtol+0x72>
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	eb 02                	jmp    800b1f <strtol+0xbc>
  800b1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800b1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b23:	74 05                	je     800b2a <strtol+0xc7>
		*endptr = (char *) s;
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b2a:	f7 d8                	neg    %eax
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	89 c6                	mov    %eax,%esi
  800b4d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b64:	89 d1                	mov    %edx,%ecx
  800b66:	89 d3                	mov    %edx,%ebx
  800b68:	89 d7                	mov    %edx,%edi
  800b6a:	89 d6                	mov    %edx,%esi
  800b6c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800b7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b81:	b8 03 00 00 00       	mov    $0x3,%eax
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	89 cb                	mov    %ecx,%ebx
  800b8b:	89 cf                	mov    %ecx,%edi
  800b8d:	89 ce                	mov    %ecx,%esi
  800b8f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b91:	85 c0                	test   %eax,%eax
  800b93:	7e 28                	jle    800bbd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b99:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba0:	00 
  800ba1:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800ba8:	00 
  800ba9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb0:	00 
  800bb1:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800bb8:	e8 c1 05 00 00       	call   80117e <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbd:	83 c4 2c             	add    $0x2c,%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd0:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd5:	89 d1                	mov    %edx,%ecx
  800bd7:	89 d3                	mov    %edx,%ebx
  800bd9:	89 d7                	mov    %edx,%edi
  800bdb:	89 d6                	mov    %edx,%esi
  800bdd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_yield>:

void
sys_yield(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c0c:	be 00 00 00 00       	mov    $0x0,%esi
  800c11:	b8 04 00 00 00       	mov    $0x4,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1f:	89 f7                	mov    %esi,%edi
  800c21:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 28                	jle    800c4f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c32:	00 
  800c33:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800c4a:	e8 2f 05 00 00       	call   80117e <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4f:	83 c4 2c             	add    $0x2c,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 28                	jle    800ca2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c85:	00 
  800c86:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800c9d:	e8 dc 04 00 00       	call   80117e <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca2:	83 c4 2c             	add    $0x2c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 28                	jle    800cf5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800cf0:	e8 89 04 00 00       	call   80117e <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf5:	83 c4 2c             	add    $0x2c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 28                	jle    800d48 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d24:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800d43:	e8 36 04 00 00       	call   80117e <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d48:	83 c4 2c             	add    $0x2c,%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800d59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 df                	mov    %ebx,%edi
  800d6b:	89 de                	mov    %ebx,%esi
  800d6d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	7e 28                	jle    800d9b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d77:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7e:	00 
  800d7f:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8e:	00 
  800d8f:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800d96:	e8 e3 03 00 00       	call   80117e <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9b:	83 c4 2c             	add    $0x2c,%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da9:	be 00 00 00 00       	mov    $0x0,%esi
  800dae:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800dcf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 cb                	mov    %ecx,%ebx
  800dde:	89 cf                	mov    %ecx,%edi
  800de0:	89 ce                	mov    %ecx,%esi
  800de2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de4:	85 c0                	test   %eax,%eax
  800de6:	7e 28                	jle    800e10 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dec:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800df3:	00 
  800df4:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  800dfb:	00 
  800dfc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e03:	00 
  800e04:	c7 04 24 21 18 80 00 	movl   $0x801821,(%esp)
  800e0b:	e8 6e 03 00 00       	call   80117e <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e10:	83 c4 2c             	add    $0x2c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 20             	sub    $0x20,%esp
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e23:	8b 30                	mov    (%eax),%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR))
  800e25:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e29:	75 1c                	jne    800e47 <pgfault+0x2f>
		panic("pgfault: not writable\n");
  800e2b:	c7 44 24 08 2f 18 80 	movl   $0x80182f,0x8(%esp)
  800e32:	00 
  800e33:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e3a:	00 
  800e3b:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  800e42:	e8 37 03 00 00       	call   80117e <_panic>
	
	if (!(uvpt[ (uintptr_t)addr >> PTXSHIFT] & PTE_COW))
  800e47:	89 f0                	mov    %esi,%eax
  800e49:	c1 e8 0c             	shr    $0xc,%eax
  800e4c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e53:	f6 c4 08             	test   $0x8,%ah
  800e56:	75 1c                	jne    800e74 <pgfault+0x5c>
		panic("pgfault: not COW page\n");
  800e58:	c7 44 24 08 51 18 80 	movl   $0x801851,0x8(%esp)
  800e5f:	00 
  800e60:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800e67:	00 
  800e68:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  800e6f:	e8 0a 03 00 00       	call   80117e <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800e74:	e8 4c fd ff ff       	call   800bc5 <sys_getenvid>
  800e79:	89 c3                	mov    %eax,%ebx

	if ((r = sys_page_alloc(envid, PFTEMP, (PTE_U|PTE_W))) < 0)
  800e7b:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800e82:	00 
  800e83:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e8a:	00 
  800e8b:	89 04 24             	mov    %eax,(%esp)
  800e8e:	e8 70 fd ff ff       	call   800c03 <sys_page_alloc>
  800e93:	85 c0                	test   %eax,%eax
  800e95:	79 20                	jns    800eb7 <pgfault+0x9f>
		panic("pgfault: sys_page_alloc() failed %e", r);
  800e97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e9b:	c7 44 24 08 8c 18 80 	movl   $0x80188c,0x8(%esp)
  800ea2:	00 
  800ea3:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800eaa:	00 
  800eab:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  800eb2:	e8 c7 02 00 00       	call   80117e <_panic>

	//memcpy( (void *)PFTEMP, (void *)PTE_ADDR(addr), PGSIZE );
	memcpy( (void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE );
  800eb7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  800ebd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ec4:	00 
  800ec5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ec9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ed0:	e8 17 fb ff ff       	call   8009ec <memcpy>

	if ((r = sys_page_map(envid, (void *)PFTEMP, envid, (void *)ROUNDDOWN(addr, PGSIZE), (PTE_U|PTE_W))) < 0)
  800ed5:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
  800edc:	00 
  800edd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ee1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ee5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800eec:	00 
  800eed:	89 1c 24             	mov    %ebx,(%esp)
  800ef0:	e8 62 fd ff ff       	call   800c57 <sys_page_map>
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	79 20                	jns    800f19 <pgfault+0x101>
		panic("pgfault: sys_page_map() failed %e", r);
  800ef9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800efd:	c7 44 24 08 b0 18 80 	movl   $0x8018b0,0x8(%esp)
  800f04:	00 
  800f05:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800f0c:	00 
  800f0d:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  800f14:	e8 65 02 00 00       	call   80117e <_panic>
	
	if ((r = sys_page_unmap(envid, (void *)PFTEMP)) < 0)
  800f19:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f20:	00 
  800f21:	89 1c 24             	mov    %ebx,(%esp)
  800f24:	e8 81 fd ff ff       	call   800caa <sys_page_unmap>
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 20                	jns    800f4d <pgfault+0x135>
		panic("pgfault: sys_page_unmap() failed %e", r);
  800f2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f31:	c7 44 24 08 d4 18 80 	movl   $0x8018d4,0x8(%esp)
  800f38:	00 
  800f39:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  800f40:	00 
  800f41:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  800f48:	e8 31 02 00 00       	call   80117e <_panic>


	//panic("pgfault not implemented");
}
  800f4d:	83 c4 20             	add    $0x20,%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    

00800f54 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	57                   	push   %edi
  800f58:	56                   	push   %esi
  800f59:	53                   	push   %ebx
  800f5a:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	envid_t envid;
	uint8_t *addr;
	int r;

	set_pgfault_handler(pgfault);
  800f5d:	c7 04 24 18 0e 80 00 	movl   $0x800e18,(%esp)
  800f64:	e8 6b 02 00 00       	call   8011d4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f69:	b8 07 00 00 00       	mov    $0x7,%eax
  800f6e:	cd 30                	int    $0x30
  800f70:	89 c7                	mov    %eax,%edi
  800f72:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid = sys_exofork();

	extern volatile pde_t uvpd[];
	extern volatile pte_t uvpt[];

	if (envid < 0)
  800f75:	85 c0                	test   %eax,%eax
  800f77:	0f 88 d3 01 00 00    	js     801150 <fork+0x1fc>
		return envid;

	if (envid == 0)
  800f7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f82:	85 c0                	test   %eax,%eax
  800f84:	75 21                	jne    800fa7 <fork+0x53>
	{
		envid = sys_getenvid();
  800f86:	e8 3a fc ff ff       	call   800bc5 <sys_getenvid>

		thisenv = &envs[ENVX(envid)];
  800f8b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f90:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f93:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f98:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa2:	e9 ad 01 00 00       	jmp    801154 <fork+0x200>
	}
	
	for ( uintptr_t va = 0; va < UTOP; )
	{
		if ((uvpd[va >> PDXSHIFT] & PTE_P) == 0)
  800fa7:	89 d8                	mov    %ebx,%eax
  800fa9:	c1 e8 16             	shr    $0x16,%eax
  800fac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb3:	a8 01                	test   $0x1,%al
  800fb5:	75 0b                	jne    800fc2 <fork+0x6e>
		{
			va += NPTENTRIES * PGSIZE;
  800fb7:	81 c3 00 00 40 00    	add    $0x400000,%ebx
			continue;
  800fbd:	e9 22 01 00 00       	jmp    8010e4 <fork+0x190>
		}
		
		if ((uvpt[va >> PTXSHIFT] & PTE_P) == 0)
  800fc2:	89 d8                	mov    %ebx,%eax
  800fc4:	c1 e8 0c             	shr    $0xc,%eax
  800fc7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fce:	a8 01                	test   $0x1,%al
  800fd0:	75 0b                	jne    800fdd <fork+0x89>
		{
			va += PGSIZE;
  800fd2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
			continue;
  800fd8:	e9 07 01 00 00       	jmp    8010e4 <fork+0x190>
		}
		
		if (va == (UXSTACKTOP - PGSIZE))
  800fdd:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fe3:	0f 84 07 01 00 00    	je     8010f0 <fork+0x19c>
		{
			va += PGSIZE;
			continue;
		}

		if ((r = duppage(envid, (unsigned) (va/PGSIZE))) < 0)
  800fe9:	89 d8                	mov    %ebx,%eax
  800feb:	c1 e8 0c             	shr    $0xc,%eax
  800fee:	89 c6                	mov    %eax,%esi
	envid_t p_envid = sys_getenvid();
  800ff0:	e8 d0 fb ff ff       	call   800bc5 <sys_getenvid>
  800ff5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	intptr_t va = (intptr_t)(pn * PGSIZE);
  800ff8:	89 f0                	mov    %esi,%eax
  800ffa:	c1 e6 0c             	shl    $0xc,%esi
	if ( (uvpt[pn]) & (PTE_COW | PTE_W))
  800ffd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801004:	a9 02 08 00 00       	test   $0x802,%eax
  801009:	0f 84 89 00 00 00    	je     801098 <fork+0x144>
		if ( (r = sys_page_map(p_envid , (void *)va, envid, (void *)va, (PTE_COW | PTE_U))) < 0 )
  80100f:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  801016:	00 
  801017:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80101b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80101e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801022:	89 74 24 04          	mov    %esi,0x4(%esp)
  801026:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801029:	89 04 24             	mov    %eax,(%esp)
  80102c:	e8 26 fc ff ff       	call   800c57 <sys_page_map>
  801031:	85 c0                	test   %eax,%eax
  801033:	79 20                	jns    801055 <fork+0x101>
			panic("duppage: %e", r);
  801035:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801039:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  801040:	00 
  801041:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801048:	00 
  801049:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  801050:	e8 29 01 00 00       	call   80117e <_panic>
		if ( (r = sys_page_map(p_envid , (void *)va, p_envid, (void *)va,  (PTE_COW | PTE_U) )) < 0 )
  801055:	c7 44 24 10 04 08 00 	movl   $0x804,0x10(%esp)
  80105c:	00 
  80105d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801061:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801064:	89 44 24 08          	mov    %eax,0x8(%esp)
  801068:	89 74 24 04          	mov    %esi,0x4(%esp)
  80106c:	89 04 24             	mov    %eax,(%esp)
  80106f:	e8 e3 fb ff ff       	call   800c57 <sys_page_map>
  801074:	85 c0                	test   %eax,%eax
  801076:	79 66                	jns    8010de <fork+0x18a>
			panic("duppage: %e", r);
  801078:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80107c:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  801083:	00 
  801084:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  80108b:	00 
  80108c:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  801093:	e8 e6 00 00 00       	call   80117e <_panic>
		if ( (r = sys_page_map(p_envid, (void *)va, envid, (void *)va, PTE_U)) < 0 )
  801098:	c7 44 24 10 04 00 00 	movl   $0x4,0x10(%esp)
  80109f:	00 
  8010a0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b2:	89 04 24             	mov    %eax,(%esp)
  8010b5:	e8 9d fb ff ff       	call   800c57 <sys_page_map>
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	79 20                	jns    8010de <fork+0x18a>
			panic("duppage: %e", r);
  8010be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010c2:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  8010c9:	00 
  8010ca:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8010d1:	00 
  8010d2:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  8010d9:	e8 a0 00 00 00       	call   80117e <_panic>
			return r;

		va += PGSIZE;
  8010de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for ( uintptr_t va = 0; va < UTOP; )
  8010e4:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8010ea:	0f 86 b7 fe ff ff    	jbe    800fa7 <fork+0x53>
	}

	if ( (r = sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), (PTE_U | PTE_W))) < 0)
  8010f0:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8010f7:	00 
  8010f8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010ff:	ee 
  801100:	89 3c 24             	mov    %edi,(%esp)
  801103:	e8 fb fa ff ff       	call   800c03 <sys_page_alloc>
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 48                	js     801154 <fork+0x200>
		return r;

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80110c:	c7 44 24 04 61 12 80 	movl   $0x801261,0x4(%esp)
  801113:	00 
  801114:	89 3c 24             	mov    %edi,(%esp)
  801117:	e8 34 fc ff ff       	call   800d50 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80111c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801123:	00 
  801124:	89 3c 24             	mov    %edi,(%esp)
  801127:	e8 d1 fb ff ff       	call   800cfd <sys_env_set_status>
  80112c:	85 c0                	test   %eax,%eax
  80112e:	79 22                	jns    801152 <fork+0x1fe>
		panic("fork: sys_env_set_status() failed %e", r);
  801130:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801134:	c7 44 24 08 f8 18 80 	movl   $0x8018f8,0x8(%esp)
  80113b:	00 
  80113c:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  801143:	00 
  801144:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  80114b:	e8 2e 00 00 00       	call   80117e <_panic>
  801150:	eb 02                	jmp    801154 <fork+0x200>

	//panic("fork not implemented");
	return envid;
  801152:	89 f8                	mov    %edi,%eax
}
  801154:	83 c4 2c             	add    $0x2c,%esp
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <sfork>:

// Challenge!
int
sfork(void)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801162:	c7 44 24 08 74 18 80 	movl   $0x801874,0x8(%esp)
  801169:	00 
  80116a:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  801171:	00 
  801172:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  801179:	e8 00 00 00 00       	call   80117e <_panic>

0080117e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	56                   	push   %esi
  801182:	53                   	push   %ebx
  801183:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801186:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801189:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80118f:	e8 31 fa ff ff       	call   800bc5 <sys_getenvid>
  801194:	8b 55 0c             	mov    0xc(%ebp),%edx
  801197:	89 54 24 10          	mov    %edx,0x10(%esp)
  80119b:	8b 55 08             	mov    0x8(%ebp),%edx
  80119e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011a2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011aa:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  8011b1:	e8 08 f0 ff ff       	call   8001be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8011bd:	89 04 24             	mov    %eax,(%esp)
  8011c0:	e8 98 ef ff ff       	call   80015d <vcprintf>
	cprintf("\n");
  8011c5:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  8011cc:	e8 ed ef ff ff       	call   8001be <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011d1:	cc                   	int3   
  8011d2:	eb fd                	jmp    8011d1 <_panic+0x53>

008011d4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011db:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8011e2:	75 6f                	jne    801253 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8011e4:	e8 dc f9 ff ff       	call   800bc5 <sys_getenvid>
  8011e9:	89 c3                	mov    %eax,%ebx
		
		if ( (r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), (PTE_U | PTE_W | PTE_P))) < 0 )
  8011eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011fa:	ee 
  8011fb:	89 04 24             	mov    %eax,(%esp)
  8011fe:	e8 00 fa ff ff       	call   800c03 <sys_page_alloc>
  801203:	85 c0                	test   %eax,%eax
  801205:	79 1c                	jns    801223 <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc() failed\n");
  801207:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  80120e:	00 
  80120f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801216:	00 
  801217:	c7 04 24 a8 19 80 00 	movl   $0x8019a8,(%esp)
  80121e:	e8 5b ff ff ff       	call   80117e <_panic>
		
		if ( (r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0 )
  801223:	c7 44 24 04 61 12 80 	movl   $0x801261,0x4(%esp)
  80122a:	00 
  80122b:	89 1c 24             	mov    %ebx,(%esp)
  80122e:	e8 1d fb ff ff       	call   800d50 <sys_env_set_pgfault_upcall>
  801233:	85 c0                	test   %eax,%eax
  801235:	79 1c                	jns    801253 <set_pgfault_handler+0x7f>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  801237:	c7 44 24 08 74 19 80 	movl   $0x801974,0x8(%esp)
  80123e:	00 
  80123f:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  801246:	00 
  801247:	c7 04 24 a8 19 80 00 	movl   $0x8019a8,(%esp)
  80124e:	e8 2b ff ff ff       	call   80117e <_panic>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80125b:	83 c4 14             	add    $0x14,%esp
  80125e:	5b                   	pop    %ebx
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801261:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801262:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801267:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801269:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	add $8, %esp
  80126c:	83 c4 08             	add    $0x8,%esp
	mov 32(%esp), %ebx
  80126f:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	mov 40(%esp), %eax
  801273:	8b 44 24 28          	mov    0x28(%esp),%eax
	sub $4, %eax
  801277:	83 e8 04             	sub    $0x4,%eax
	mov %ebx, (%eax)
  80127a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popa
  80127c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  80127d:	83 c4 04             	add    $0x4,%esp
	popf
  801280:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop	%esp
  801281:	5c                   	pop    %esp
	

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp
  801282:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  801286:	c3                   	ret    
  801287:	66 90                	xchg   %ax,%ax
  801289:	66 90                	xchg   %ax,%ax
  80128b:	66 90                	xchg   %ax,%ax
  80128d:	66 90                	xchg   %ax,%ax
  80128f:	90                   	nop

00801290 <__udivdi3>:
  801290:	55                   	push   %ebp
  801291:	57                   	push   %edi
  801292:	56                   	push   %esi
  801293:	83 ec 0c             	sub    $0xc,%esp
  801296:	8b 44 24 28          	mov    0x28(%esp),%eax
  80129a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80129e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8012a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012ac:	89 ea                	mov    %ebp,%edx
  8012ae:	89 0c 24             	mov    %ecx,(%esp)
  8012b1:	75 2d                	jne    8012e0 <__udivdi3+0x50>
  8012b3:	39 e9                	cmp    %ebp,%ecx
  8012b5:	77 61                	ja     801318 <__udivdi3+0x88>
  8012b7:	85 c9                	test   %ecx,%ecx
  8012b9:	89 ce                	mov    %ecx,%esi
  8012bb:	75 0b                	jne    8012c8 <__udivdi3+0x38>
  8012bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c2:	31 d2                	xor    %edx,%edx
  8012c4:	f7 f1                	div    %ecx
  8012c6:	89 c6                	mov    %eax,%esi
  8012c8:	31 d2                	xor    %edx,%edx
  8012ca:	89 e8                	mov    %ebp,%eax
  8012cc:	f7 f6                	div    %esi
  8012ce:	89 c5                	mov    %eax,%ebp
  8012d0:	89 f8                	mov    %edi,%eax
  8012d2:	f7 f6                	div    %esi
  8012d4:	89 ea                	mov    %ebp,%edx
  8012d6:	83 c4 0c             	add    $0xc,%esp
  8012d9:	5e                   	pop    %esi
  8012da:	5f                   	pop    %edi
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    
  8012dd:	8d 76 00             	lea    0x0(%esi),%esi
  8012e0:	39 e8                	cmp    %ebp,%eax
  8012e2:	77 24                	ja     801308 <__udivdi3+0x78>
  8012e4:	0f bd e8             	bsr    %eax,%ebp
  8012e7:	83 f5 1f             	xor    $0x1f,%ebp
  8012ea:	75 3c                	jne    801328 <__udivdi3+0x98>
  8012ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012f0:	39 34 24             	cmp    %esi,(%esp)
  8012f3:	0f 86 9f 00 00 00    	jbe    801398 <__udivdi3+0x108>
  8012f9:	39 d0                	cmp    %edx,%eax
  8012fb:	0f 82 97 00 00 00    	jb     801398 <__udivdi3+0x108>
  801301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801308:	31 d2                	xor    %edx,%edx
  80130a:	31 c0                	xor    %eax,%eax
  80130c:	83 c4 0c             	add    $0xc,%esp
  80130f:	5e                   	pop    %esi
  801310:	5f                   	pop    %edi
  801311:	5d                   	pop    %ebp
  801312:	c3                   	ret    
  801313:	90                   	nop
  801314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801318:	89 f8                	mov    %edi,%eax
  80131a:	f7 f1                	div    %ecx
  80131c:	31 d2                	xor    %edx,%edx
  80131e:	83 c4 0c             	add    $0xc,%esp
  801321:	5e                   	pop    %esi
  801322:	5f                   	pop    %edi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    
  801325:	8d 76 00             	lea    0x0(%esi),%esi
  801328:	89 e9                	mov    %ebp,%ecx
  80132a:	8b 3c 24             	mov    (%esp),%edi
  80132d:	d3 e0                	shl    %cl,%eax
  80132f:	89 c6                	mov    %eax,%esi
  801331:	b8 20 00 00 00       	mov    $0x20,%eax
  801336:	29 e8                	sub    %ebp,%eax
  801338:	89 c1                	mov    %eax,%ecx
  80133a:	d3 ef                	shr    %cl,%edi
  80133c:	89 e9                	mov    %ebp,%ecx
  80133e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801342:	8b 3c 24             	mov    (%esp),%edi
  801345:	09 74 24 08          	or     %esi,0x8(%esp)
  801349:	89 d6                	mov    %edx,%esi
  80134b:	d3 e7                	shl    %cl,%edi
  80134d:	89 c1                	mov    %eax,%ecx
  80134f:	89 3c 24             	mov    %edi,(%esp)
  801352:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801356:	d3 ee                	shr    %cl,%esi
  801358:	89 e9                	mov    %ebp,%ecx
  80135a:	d3 e2                	shl    %cl,%edx
  80135c:	89 c1                	mov    %eax,%ecx
  80135e:	d3 ef                	shr    %cl,%edi
  801360:	09 d7                	or     %edx,%edi
  801362:	89 f2                	mov    %esi,%edx
  801364:	89 f8                	mov    %edi,%eax
  801366:	f7 74 24 08          	divl   0x8(%esp)
  80136a:	89 d6                	mov    %edx,%esi
  80136c:	89 c7                	mov    %eax,%edi
  80136e:	f7 24 24             	mull   (%esp)
  801371:	39 d6                	cmp    %edx,%esi
  801373:	89 14 24             	mov    %edx,(%esp)
  801376:	72 30                	jb     8013a8 <__udivdi3+0x118>
  801378:	8b 54 24 04          	mov    0x4(%esp),%edx
  80137c:	89 e9                	mov    %ebp,%ecx
  80137e:	d3 e2                	shl    %cl,%edx
  801380:	39 c2                	cmp    %eax,%edx
  801382:	73 05                	jae    801389 <__udivdi3+0xf9>
  801384:	3b 34 24             	cmp    (%esp),%esi
  801387:	74 1f                	je     8013a8 <__udivdi3+0x118>
  801389:	89 f8                	mov    %edi,%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	e9 7a ff ff ff       	jmp    80130c <__udivdi3+0x7c>
  801392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801398:	31 d2                	xor    %edx,%edx
  80139a:	b8 01 00 00 00       	mov    $0x1,%eax
  80139f:	e9 68 ff ff ff       	jmp    80130c <__udivdi3+0x7c>
  8013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	83 c4 0c             	add    $0xc,%esp
  8013b0:	5e                   	pop    %esi
  8013b1:	5f                   	pop    %edi
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    
  8013b4:	66 90                	xchg   %ax,%ax
  8013b6:	66 90                	xchg   %ax,%ax
  8013b8:	66 90                	xchg   %ax,%ax
  8013ba:	66 90                	xchg   %ax,%ax
  8013bc:	66 90                	xchg   %ax,%ax
  8013be:	66 90                	xchg   %ax,%ax

008013c0 <__umoddi3>:
  8013c0:	55                   	push   %ebp
  8013c1:	57                   	push   %edi
  8013c2:	56                   	push   %esi
  8013c3:	83 ec 14             	sub    $0x14,%esp
  8013c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8013d2:	89 c7                	mov    %eax,%edi
  8013d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8013dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013e0:	89 34 24             	mov    %esi,(%esp)
  8013e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013ef:	75 17                	jne    801408 <__umoddi3+0x48>
  8013f1:	39 fe                	cmp    %edi,%esi
  8013f3:	76 4b                	jbe    801440 <__umoddi3+0x80>
  8013f5:	89 c8                	mov    %ecx,%eax
  8013f7:	89 fa                	mov    %edi,%edx
  8013f9:	f7 f6                	div    %esi
  8013fb:	89 d0                	mov    %edx,%eax
  8013fd:	31 d2                	xor    %edx,%edx
  8013ff:	83 c4 14             	add    $0x14,%esp
  801402:	5e                   	pop    %esi
  801403:	5f                   	pop    %edi
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    
  801406:	66 90                	xchg   %ax,%ax
  801408:	39 f8                	cmp    %edi,%eax
  80140a:	77 54                	ja     801460 <__umoddi3+0xa0>
  80140c:	0f bd e8             	bsr    %eax,%ebp
  80140f:	83 f5 1f             	xor    $0x1f,%ebp
  801412:	75 5c                	jne    801470 <__umoddi3+0xb0>
  801414:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801418:	39 3c 24             	cmp    %edi,(%esp)
  80141b:	0f 87 e7 00 00 00    	ja     801508 <__umoddi3+0x148>
  801421:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801425:	29 f1                	sub    %esi,%ecx
  801427:	19 c7                	sbb    %eax,%edi
  801429:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80142d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801431:	8b 44 24 08          	mov    0x8(%esp),%eax
  801435:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801439:	83 c4 14             	add    $0x14,%esp
  80143c:	5e                   	pop    %esi
  80143d:	5f                   	pop    %edi
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    
  801440:	85 f6                	test   %esi,%esi
  801442:	89 f5                	mov    %esi,%ebp
  801444:	75 0b                	jne    801451 <__umoddi3+0x91>
  801446:	b8 01 00 00 00       	mov    $0x1,%eax
  80144b:	31 d2                	xor    %edx,%edx
  80144d:	f7 f6                	div    %esi
  80144f:	89 c5                	mov    %eax,%ebp
  801451:	8b 44 24 04          	mov    0x4(%esp),%eax
  801455:	31 d2                	xor    %edx,%edx
  801457:	f7 f5                	div    %ebp
  801459:	89 c8                	mov    %ecx,%eax
  80145b:	f7 f5                	div    %ebp
  80145d:	eb 9c                	jmp    8013fb <__umoddi3+0x3b>
  80145f:	90                   	nop
  801460:	89 c8                	mov    %ecx,%eax
  801462:	89 fa                	mov    %edi,%edx
  801464:	83 c4 14             	add    $0x14,%esp
  801467:	5e                   	pop    %esi
  801468:	5f                   	pop    %edi
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    
  80146b:	90                   	nop
  80146c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801470:	8b 04 24             	mov    (%esp),%eax
  801473:	be 20 00 00 00       	mov    $0x20,%esi
  801478:	89 e9                	mov    %ebp,%ecx
  80147a:	29 ee                	sub    %ebp,%esi
  80147c:	d3 e2                	shl    %cl,%edx
  80147e:	89 f1                	mov    %esi,%ecx
  801480:	d3 e8                	shr    %cl,%eax
  801482:	89 e9                	mov    %ebp,%ecx
  801484:	89 44 24 04          	mov    %eax,0x4(%esp)
  801488:	8b 04 24             	mov    (%esp),%eax
  80148b:	09 54 24 04          	or     %edx,0x4(%esp)
  80148f:	89 fa                	mov    %edi,%edx
  801491:	d3 e0                	shl    %cl,%eax
  801493:	89 f1                	mov    %esi,%ecx
  801495:	89 44 24 08          	mov    %eax,0x8(%esp)
  801499:	8b 44 24 10          	mov    0x10(%esp),%eax
  80149d:	d3 ea                	shr    %cl,%edx
  80149f:	89 e9                	mov    %ebp,%ecx
  8014a1:	d3 e7                	shl    %cl,%edi
  8014a3:	89 f1                	mov    %esi,%ecx
  8014a5:	d3 e8                	shr    %cl,%eax
  8014a7:	89 e9                	mov    %ebp,%ecx
  8014a9:	09 f8                	or     %edi,%eax
  8014ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8014af:	f7 74 24 04          	divl   0x4(%esp)
  8014b3:	d3 e7                	shl    %cl,%edi
  8014b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014b9:	89 d7                	mov    %edx,%edi
  8014bb:	f7 64 24 08          	mull   0x8(%esp)
  8014bf:	39 d7                	cmp    %edx,%edi
  8014c1:	89 c1                	mov    %eax,%ecx
  8014c3:	89 14 24             	mov    %edx,(%esp)
  8014c6:	72 2c                	jb     8014f4 <__umoddi3+0x134>
  8014c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8014cc:	72 22                	jb     8014f0 <__umoddi3+0x130>
  8014ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014d2:	29 c8                	sub    %ecx,%eax
  8014d4:	19 d7                	sbb    %edx,%edi
  8014d6:	89 e9                	mov    %ebp,%ecx
  8014d8:	89 fa                	mov    %edi,%edx
  8014da:	d3 e8                	shr    %cl,%eax
  8014dc:	89 f1                	mov    %esi,%ecx
  8014de:	d3 e2                	shl    %cl,%edx
  8014e0:	89 e9                	mov    %ebp,%ecx
  8014e2:	d3 ef                	shr    %cl,%edi
  8014e4:	09 d0                	or     %edx,%eax
  8014e6:	89 fa                	mov    %edi,%edx
  8014e8:	83 c4 14             	add    $0x14,%esp
  8014eb:	5e                   	pop    %esi
  8014ec:	5f                   	pop    %edi
  8014ed:	5d                   	pop    %ebp
  8014ee:	c3                   	ret    
  8014ef:	90                   	nop
  8014f0:	39 d7                	cmp    %edx,%edi
  8014f2:	75 da                	jne    8014ce <__umoddi3+0x10e>
  8014f4:	8b 14 24             	mov    (%esp),%edx
  8014f7:	89 c1                	mov    %eax,%ecx
  8014f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8014fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801501:	eb cb                	jmp    8014ce <__umoddi3+0x10e>
  801503:	90                   	nop
  801504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801508:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80150c:	0f 82 0f ff ff ff    	jb     801421 <__umoddi3+0x61>
  801512:	e9 1a ff ff ff       	jmp    801431 <__umoddi3+0x71>
