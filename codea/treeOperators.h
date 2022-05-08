#ifndef TREE_OPERATORS_H
#define TREE_OPERATORS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

treenode *newOperatorNode(int op, treenode *left, treenode *right);
treenode *newRegisterNode(char* name);
treenode *newNumberNode(long num);
treenode *newVariableNode(char* str);

#endif