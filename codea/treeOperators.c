#include "treeOperators.h"

treenode *newOperatorNode(int op, treenode *left, treenode *right)
{
  treenode *newNode = malloc(sizeof(treenode));

  if (newNode == NULL) { printf("Out of memory.\n"); exit(4);}

  newNode->op = op;
  newNode->kids[0] = left;
  newNode->kids[1] = right;
  newNode->regname=0;
  newNode->val=0;

  return newNode;
}

treenode *newRegisterNode(char* regname)
{
  treenode *newNode = newOperatorNode(REGISTER,NULL,NULL);
  newNode->regname = regname;
  return newNode;
}

treenode *newNumberNode(long num)
{
  treenode *newNode = newOperatorNode(NUMBER,NULL,NULL);
  newNode->val = num;
  return newNode;
}

treenode *newVariableNode(char* str)
{
  treenode *newNode = newOperatorNode(VARIABLE,NULL,NULL);
  newNode->str = str;
  return newNode;
}