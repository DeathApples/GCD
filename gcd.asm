format ELF64 ; binary format
public _start ; program entry point



section "Bufer" writable
    output_string rb 255
    input_number rb 21
    input_size equ 21
    output_byte rb 1



section "Data" writable
    message_1 db 0xA, 'Введите первое число: ', 0
    message_2 db 'Введите второе число: ', 0
    message_3 db 0xA, 'НОД = ', 0
    number_1 rq 1
    number_2 rq 1



section "Main" executable
_start:
    mov rax, message_1
    call print_line
    mov rax, number_1
    call read_integer

    mov rax, message_2
    call print_line
    mov rax, number_2
    call read_integer

    mov rax, message_3
    call print_line

    mov rax, [number_1]
    mov rbx, [number_2]
    call nod

    call to_string
    call print_line

    call _exit



section "Nod" executable
; | input:
; rax = number_1
; rbx = number_2
; | output:
; rax = nod
nod:
    push rbx

    .next_iter:
        cmp rbx, 0
        je .close
        xor rdx, rdx
        div rbx
        push rbx
        mov rbx, rdx
        pop rax
        jmp .next_iter

    .close:
        pop rbx

        ret



section "ReadLine" executable
; | input:
; rax = line
; rbx = size_line
read_line:
    push rdx
    push rcx
    push rbx
    push rax
    
    mov rcx, rax
    mov rdx, rbx
    mov rax, 3 ; command read
    mov rbx, 2 ; 2 - stdin
    int 0x80

    mov rbx, [rsp]
    mov [rax + rbx - 1], byte 0

    pop rax
    pop rbx
    pop rcx
    pop rdx

    ret



section "ReadInteger" executable
; | input:
; rax = ptr(integer)
read_integer:
    push rbx
    push rax

    mov rax, input_number
    mov rbx, input_size
    call read_line
    call to_integer

    mov rbx, rax
    pop rax
    mov [rax], rbx

    pop rbx
    
    ret



section "PrintChar" executable
; | input:
; output_byte = char
print_char:
    push rax
    push rbx
    push rcx
    push rdx
    
    mov rax, 4 ; command write
    mov rbx, 1 ; 1 - stdout | 2 - stdin | 3 - stderr
    mov rcx, output_byte ; value to output
    mov rdx, 1 ; number of characters
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret



section "PrintLine" executable
; | input:
; rax = ptr(string)
print_line:
    push rax
    push rbx
    push rcx

    xor rbx, rbx

    .print:
        mov cl, [rax + rbx]
        cmp cl, 0
        je .close
        mov [output_byte], cl
        call print_char
        inc rbx
        jmp .print

    .close:
        pop rcx
        pop rbx
        pop rax

        ret



section "ToString" executable
; | input:
; rax = integer
; | output:
; rax = ptr(string)
; output_string = string
to_string:
    push rbx
    push rcx
    push rdx

    xor rcx, rcx

    .next_iter:
        mov rbx, 10 ; 10 - current divisor
        xor rdx, rdx ; zeroing rdx
        div rbx ; dividing rax by rbx
        add rdx, '0' ; converting to char
        push rdx ; remember remainder of current division
        inc rcx ; increase number of remainders
        cmp rax, 0 ; cmp - comparison of values
        je .continue ; print remainder
        jmp .next_iter ; continue dividing

    .continue:
        xor rdx, rdx
    
    .write:
        cmp rcx, 0 ; check number of remainder
        je .save ; exit from function
        pop rbx
        mov [output_string + rdx], bl
        inc rdx ; put remainder into register for writing
        dec rcx ; decrease number of remainders
        jmp .write ; continue printing

    .save:
        mov [output_string + rdx], byte 0xA
        mov [output_string + rdx + 1], byte 0xA
        mov [output_string + rdx + 2], byte 0
        mov rax, output_string

    .close:
        pop rdx
        pop rcx
        pop rbx

        ret



section "ToInteger" executable
; | input:
; rax = string
; | output:
; rax = integer
to_integer:
    push rbx
    push rcx
    push rdx

    xor rbx, rbx

    .next_iter:
        cmp [rax + rbx], byte 0
        je .continue
        mov cl, [rax + rbx]
        sub cl, '0'
        push rcx
        inc rbx
        jmp .next_iter

    .continue:
        xor rcx, rcx
        xor rax, rax
        inc rcx
    
    .write:
        cmp rbx, 0
        je .close
        pop rdx
        imul rdx, rcx
        imul rcx, 10
        add rax, rdx
        dec rbx
        jmp .write

    .close:
        pop rdx
        pop rcx
        pop rbx

        ret



section "Exit" executable
_exit:
    mov rax, 1 ; 1 - exit
    mov rbx, 0 ; 0 - return value
    int 0x80
