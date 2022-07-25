/*  ___________________________________________________________________________
Σχόλια:           Ο λεκτικός αναλυτής αναγνωρίζει:
                  - DELIMITER (tabs, κενά)
                  - IDENTIFIER 	(αναγνωριστικά)
                  - STRING (Συμβολοσειρές)
                  - INTEGER (Ακέραιοι δεκαδικού, οκταδικού και δεκαεξ. συστ.)
                  - FLOAT (Αρ. κινούμενης υποδ/λής, δεκαδικός αρ. ή δύναμη)
                  - COMMENT_LONG (Μεγάλο σχόλιο)
                  - COMMENT_SHORT (σχόλιο μιας γραμμής)
                  - UNKNOWNS (Μη αναγνωρίσιμα tokens)
                  - Δεσμευμένες λέξεις κλειδιά
                  - Ειδικούς χαρακτήρες
                  - Ενσωματομένες συναρτήσεις της Uni-C
                  - Καταμέτρηση whitespace και γραμμών κώδικα

                  Bugs/Unimplemented
                  - Δεν έχει υλοποιηθεί η σύνδεση φυσικών γραμμών με \
    ___________________________________________________________________________
*/

%option noyywrap

/* ____________________________________________________________________________
   Κώδικας C για ορισμό των απαιρούμενων header files και των μεταβλητών.
   Οτιδήποτε ανάμεσα στα %{ και %} μςταφέρεται αυτούσιο στο αρχείο C που θα
   δημιουργήσει το Flex.
   ____________________________________________________________________________
*/

%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Header file που περιέχει λίστα με όλα τα tokens
#include "team6.tab.h"

extern int flag; 
extern int line; // Μετρητής γραμμών κώδικα
extern int white_space=0; // Μετρητής κενών & tabs
extern int lc_check=0; // Μετρητής λεκτικών σωστών
extern int le_check=0; // Μετρητής λεκτικών σφαλμάτων

void prn(char *s);

%}

/* ____________________________________________________________________________
   Ονόματα και αντίστοιχοι ορισμοί (υπό μορφή κανονικής έκφρασης).
   Μετά από αυτό, μπορεί να γίνει χρήση των ονομάτων (αριστερά) αντί των,
   συνήθως ιδιαιτέρως μακρόσκελων και δυσνόητων κανονικών εκφράσεων.
   ____________________________________________________________________________
*/

DELIMITER      [\t\s ]
IDENTIFIER     (_|[a-z]|[A-Z])(_|[0-9]|[a-z]|[A-Z])*
STRING         ["]([^"\\\n]|\.|\\\n)*["]
INTEGER        (0|[1-9]+[0-9]*)|(0X([0-9]|[A-F])+|0x([0-9]|[A-F])+)|(0[0-7]+)
FLOAT          [0-9]+((\.[0-9]+((e|E)(-?([0]|[0-9]+|[1-9])))?)|((e|E)(-?([0]|[0-9]+|[1-9]))))
COMMENT_LONG   \/\*[^*]*\*\/
COMMENT_SHORT  (\/\/)+.*
UNKNOWNS       [$@`#]+


/* ____________________________________________________________________________
   Για κάθε pattern (αριστερά) που ταιριάζει εκτελείται ο αντίστοιχος κώδικας
   μέσα στα άγκιστρα. Η εντολή return επιτρέπει την επιστροφή μιας 
   συγκεκριμένης αριθμητικής τιμής που αντιπροσωπεύει την λεκτική μονάδα που
   διαβάστηκε. Η τιμή συτή χρησιμοποιείται από το εργαλείο Bison για την
   συντακτική ανάλυση της εισόδου.
   ____________________________________________________________________________
*/

%%

[\n]              {line++;lc_check++; white_space++; return NL;}
{DELIMITER}       {white_space++;}
"+"               {prn("PLUS");lc_check++; return PLUS;}
"-"               {prn("MINUS");lc_check++; return MINUS;}
"/"               {prn("DIV");lc_check++; return DIV;}
"*"               {prn("MULT");lc_check++; return MULT;}
"%"               {prn("MOD");lc_check++; return MOD;}
"="               {prn("EQUAL_MATH");lc_check++; return EQUAL_MATH;}
"+="              {prn("ADD_ASSIGNMENT");lc_check++; return ADD_ASSIGNMENT;}
"-="              {prn("SUB_ASSIGNMENT");lc_check++; return SUB_ASSIGNMENT;}
"*="              {prn("MULT_ASSIGNMENT");lc_check++; return MULT_ASSIGNMENT;}
"/="              {prn("DIV_ASSIGNMENT");lc_check++; return DIV_ASSIGNMENT;}
"!"               {prn("NOT");lc_check++; return NOT;}
"&&"              {prn("AND");lc_check++; return AND;}
"||"              {prn("OR");lc_check++; return OR;}
"=="              {prn("EQUAL_LOGIC");lc_check++; return EQUAL_LOGIC;}
"!="              {prn("NOT_EQUAL_LOGIC");lc_check++; return NOT_EQUAL_LOGIC;}
"++"              {prn("INCREMENT");lc_check++; return INCREMENT;}
"--"              {prn("DECREMENT");lc_check++; return DECREMENT;}
"<"               {prn("LESS_THAN");lc_check++; return LESS_THAN;}
">"               {prn("GREATER_THAN");lc_check++; return GREATER_THAN;}
"<="              {prn("LESS_EQ_THAN");lc_check++; return LESS_EQ_THAN;}
">="              {prn("GREATER_EQ_THAN");lc_check++; return GREATER_EQ_THAN;}
"&"               {prn("MEM_ADDR");lc_check++; return MEM_ADDR;}
":"               {prn("COLON");lc_check++; return COLON;}
";"               {prn("SEMICOLON");lc_check++; return SEMI;}
","               {prn("COMA");lc_check++; return COMA;}
"\""              {prn("EAR");lc_check++; return EAR;}
"["               {prn("OPEN");lc_check++; return OPEN_BRACKET;}
"]"               {prn("CLOSE");lc_check++; return CLOSE_BRACKET;}
"("               {prn("OPEN_PAR");lc_check++; return OPEN_PAR;}
")"               {prn("CLOSE_PAR");lc_check++; return CLOSE_PAR;}
"{"               {prn("OPEN_CBR");lc_check++; return OPEN_CBR;}
"}"               {prn("CLOSE_CBR");lc_check++; return CLOSE_CBR;}

"break"           {prn("RESERVED: break");lc_check++; return BREAK;}
"case"            {prn("RESERVED: case");lc_check++; return CASE;}
"func"            {prn("RESERVED: func");lc_check++; return FUNC;}
"const"           {prn("RESERVED: const");lc_check++; return CONST;}
"continue"        {prn("RESERVED: continue");lc_check++; return CONTINUE;}
"do"              {prn("RESERVED: do");lc_check++; return DO;}
"double"          {prn("RESERVED: double ");lc_check++; return TYPE_FL;} 
"else"            {prn("RESERVED: else");lc_check++; return ELSE;}
"float"           {prn("RESERVED: float");lc_check++; return TYPE_FL;}
"for"             {prn("RESERVED: for");lc_check++; return FOR;}
"if"              {prn("RESERVED: if");lc_check++; return IF;}
"int"             {prn("RESERVED: int");lc_check++; return TYPE_INT;}
"long"            {prn("RESERVED: long");lc_check++; return TYPE_INT;}
"return"          {prn("RESERVED: return");lc_check++; return RETURN;}
"short"           {prn("RESERVED: short");lc_check++; return TYPE_INT;}
"sizeof"          {prn("RESERVED: sizeof");lc_check++; return SIZEOF;}
"struct"          {prn("RESERVED: struct");lc_check++; return STRUCT;}
"switch"          {prn("RESERVED: switch");lc_check++; return SWITCH;}
"void"            {prn("RESERVED: void");lc_check++; return VOID;}
"while"           {prn("RESERVED: while");lc_check++; return WHILE;}
"scan"            {prn("BUILT IN FUNC: scan");lc_check++; return SCAN;}
"len"             {prn("BUILT IN FUNC: len");lc_check++; return LEN;}
"cmp"             {prn("BUILT IN FUNC: cmp");lc_check++; return CMP;}
"print"           {prn("BUILT IN FUNC: print");lc_check++; return PRINT;}

{INTEGER}         {prn("INTEGER VALUE");lc_check++; return INTEGER;}
{FLOAT}           {prn("FLOAT VALUE");lc_check++; return FLOAT;}
{STRING}          {prn("STRING VALUE");lc_check++; return STRING;}
{IDENTIFIER} 		{prn("IDENTIFIER");lc_check++; return IDENTIFIER;}
{COMMENT_LONG}    {prn("COMMENT LONG");
							lc_check++;
							char* str = yytext;
        					int i = 0;
        					char *pch=strchr(str,'\n');
        					while (pch!=NULL) {
            				i++;
            				pch=strchr(pch+1,'\n');
        					}
       					line+=i;	
       						
							return COMMENT_LONG;
						}
{COMMENT_SHORT}   {prn("COMMENT SHORT");lc_check++; return COMMENT_SHORT;}

{UNKNOWNS}        {printf("\n### Token Error '%s' ###\n",yytext); le_check++; white_space++; }

%%


/* ____________________________________________________________________________
   Η συνάρτηση prn τυπώνει στην οθόνη τον τύπου του αναγνωριστικού 
   (πχ. ASSIGNOP).
   Η συνάρτηση τυπώνει στην οθόνη τον τύπο του αναγνωριστικού που έγινε match
   καθώς και το ίδιο το κείμενο (πχ. =) του αναγνωριστικού. Ο λόγος ύπαρξης της
   είναι καθαρά για καλύτερη κατανόηση του κώδικα και για γενικότερη
   διευκόλυνση στο debugging της εφαρμογής.
   ____________________________________________________________________________
*/

void prn(char *s)
{
	printf("\n\t%s: %s ", s, yytext);
	return;
}
