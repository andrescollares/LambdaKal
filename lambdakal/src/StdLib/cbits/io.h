#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include "list.h"

double putchari(int32_t i);

int32_t printil(intList *list);

int32_t printfl(doubleList *list);

int32_t printbl(boolList *list);

char* intListToString(intList *list);

char* floatListToString(doubleList *list);

char* boolListToString(boolList *list);

double writed(double d);