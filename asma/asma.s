	.file	"asma.s"
	.text
	.globl	shuff
	.section	.rodata
	.align 16
	.type	shuff, @object
	.size	shuff, 16
shuff: /* shuffle mask for pshufb */
	.quad	0x08090A0B0C0D0E0F
	.quad	0x0001020304050607
	.text
	.globl	asma
	.type	asma, @function
asma:
.LFB0: /* local function begin 0 */
	.cfi_startproc /* start of function */
	/* function code */
	movdqu (%rdi), %xmm1 /* move the parameter to xmm1 */
	movdqu shuff(%rip), %xmm2 /* move the shuffle mask to xmm2 */
	pshufb %xmm2, %xmm1 /* shuffle the array */
	movdqu %xmm1, (%rdi) /* write the shuffled array back to the memory */
	ret
	.cfi_endproc /* end of function */
.LFE0: /* local function end 0 */
	.size	asma, .-asma
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",@progbits

/* https://stackoverflow.com/questions/15284947/understanding-gcc-s-output */

/*
%rip <- return address
%rsp <- points to register where the rest of the arguments are stored if more
		than 6 arguments are passed

%rdi, %rsi, %rdx, %rcx, %r8, %r9 <- argument register (1. = %rdi, 2. = %rsi, ...)

%rax <- return value (8 byte)
%rax %rdx <- return value (16 byte)

%r10, %r11 <- caller saved 
%rbp, %rbx, %r12, %r13, %r14, %r15 <- callee saved (function must restore them)
*/