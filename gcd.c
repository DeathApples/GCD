#include <stdio.h>

int main()
{
    int number_1, number_2;

    printf("Введите два числа через пробел: ");
    scanf("%d%d", &number_1, &number_2);

    while ((number_1 != 0) && (number_2 != 0))
    {
        if (number_1 > number_2)
            number_1 %= number_2;
        else
            number_2 %= number_1;
    }

    if(number_1 != 0)
        printf("НОД(%d; %d) = %d\n", number_1, number_2, number_1);
    else
        printf("НОД(%d; %d) = %d\n", number_1, number_2, number_2);

    return 0;
}
