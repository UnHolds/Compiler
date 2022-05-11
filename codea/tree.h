#ifndef TREE_H
#define TREE_H


#define INIT 0
#define FUNCTION 1
#define LABEL 2
#define FUNCTION_END 3
#define GOTO 4
#define VARIABLE 5
#define NUMBER 6
#define REGISTER 7
#define NOT 8
#define MINUS 9
#define PLUS 10
#define TIMES 11
#define AND 12
#define GREATER 13
#define EQUAL 14
#define RETURN 15
#define VARIABLE_ASSIGNMENT 16
#define VARIABLE_DEFINITION 17
#define TERM_EXECUTION 18
#define ARRAY_ASSIGN 19
#define IF 20
#define ARRAY_ACCESS 21
#define PARS 22
#define PARS_LAST 23

#ifdef USE_IBURG
#ifndef BURM
typedef struct burm_state *STATEPTR_TYPE;
#endif
#else
#define STATEPTR_TYPE int
#endif

typedef struct s_node {
	int		op;
	struct s_node   *kids[2];
	STATEPTR_TYPE	state;
        /* user defined data fields follow here */
	char* regName;
    int regNum;
	long num;
    char* str;
} treenode;

typedef treenode *treenodep;

#define NODEPTR_TYPE	treenodep
#define OP_LABEL(p)	((p)->op)
#define LEFT_CHILD(p)	((p)->kids[0])
#define RIGHT_CHILD(p)	((p)->kids[1])
#define STATE_LABEL(p)	((p)->state)
#define PANIC		printf

#endif
