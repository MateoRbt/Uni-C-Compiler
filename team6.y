/*  ___________________________________________________________________________
Σχόλια:           Ο συντακτικός αναλυτής αναγνωρίζει:
                  - Δηλώσεις μεταβλητών
                  - Δηλώσεις μεταβλητών με ανάθεση τιμής
                  - Ανάθεση τιμών σε μεταβλητές
                  - Integers (DEC, OCT, HEX) (10, 056, 0xFF09)
                  - Floats
                  - Αριθμητικές εκφράσεις
                  - Tελεστές - Συγκρίσεις
                  - Strings
                  - Πίνακες
                  - Δηλώσεις loops (if, while, do while, for)
                  - Functions της Uni-C (scan, len, cmp, print)
                  - Δήλωση Function (func myFunc())
                  - Δεσμευμένες λέξεις κλειδιά
                  - Μικρά και μεγάλα σχόλια
                  - Unknown Tokens
                  - Αναγνώριση, καταμέτρηση και εκτύπωση λεκτικών/γραμματικών
                    σφαλμάτων/σωστών

                  Λεκτικές μονάδες που αναγνωρίζονται από το FLEX
                  - DELIMITER (tabs, κενά)
                  - IDENTIFIER 	(αναγνωριστικά)
                  - STRING (Συμβολοσειρές)
                  - INTEGER (Ακέραιοι δεκαδικού, οκταδικού και δεκαεξ. συστ.)
                  - FLOAT (Αρ. κινούμενης υποδ/λής, δεκαδικός αρ. ή δύναμη)
                  - COMMENT_LONG (Μεγάλο σχόλιο)
                  - COMMENT_SHORT (σχόλιο μιας γραμμής)
                  - UNKNOWNS (Μη αναγνωρίσιμα tokens)

                  Bugs/Unimplemented
                  - Δεν έχει υλοποιηθεί η σύνδεση φυσικών γραμμών με \
    ___________________________________________________________________________
*/

%{

/* ____________________________________________________________________________
   Ορισμοί και δηλώσεις γλώσσας C. Οτιδήποτε έχει να κάνει με ορισμό ή 
   αρχικοποίηση μεταβλητών, αρχεία header και δηλώσεις #define μπαίνει σε αυτό
   το σημείο.
   ____________________________________________________________________________
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#define YYSTYPE int
int line=1; // Μετρητής γραμμών κώδικα
int errflag=0;
int yylex();
int yyerror(char *s);
int gc_check = 0; // Μετρητής γραμματικών σωστών
int ge_check = 0; // Μετρητης γραμματικών σφαλμάτων
extern char *yytext;
extern int *lc_check; // Μετρητής λεκτικών σωστών
extern int *le_check; // Μετρητής λεκτικών σφαλμάτων
extern int white_space; // Μετρητής κενών & tabs
%}

/* ____________________________________________________________________________
   Δηλώσεις και ορισμοί Bison 
   ____________________________________________________________________________
*/

// Ορισμός των αναγνωρίσιμων λεκτικών μονάδων 
%token INTEGER FLOAT STRING IDENTIFIER COMMENT_LONG COMMENT_SHORT NL PLUS MINUS
DIV MULT MOD EQUAL_MATH ADD_ASSIGNMENT SUB_ASSIGNMENT MULT_ASSIGNMENT
DIV_ASSIGNMENT NOT AND OR EQUAL_LOGIC NOT_EQUAL_LOGIC INCREMENT DECREMENT
LESS_THAN GREATER_THAN LESS_EQ_THAN GREATER_EQ_THAN MEM_ADDR SEMI COMA EAR
OPEN_BRACKET CLOSE_BRACKET OPEN_PAR CLOSE_PAR BREAK CASE FUNC CONST CONTINUE DO
TYPE_FL TYPE_INT ELSE FOR IF RETURN SIZEOF STRUCT SWITCH VOID WHILE SCAN LEN
CMP PRINT OPEN_CBR CLOSE_CBR COLON

// Προτεραιότητες 
%left PLUS MINUS
%left MULT DIV
%left NEG

// Ορισμός συμβόλου έναρξης της γραμματικής
%start program

%%

/* ____________________________________________________________________________
   Ορισμός των γραμματικών κανόνων. Κάθε φορά που αντιστοιχίζεται ένας 
   γραμματικός κανόνας με τα δεδομένα εισόδου, εκτελείται ο κώδικας C που 
   βρίσκεται ανάμεσα στα άγκιστρα. Η αναμενόμενη σύνταξη είναι:
   
   name : rule {C code}
   ____________________________________________________________________________
*/
					    
program  : program expr NL {printf("\n");}
         | program comm
         | program assign NL
         | program val NL
         | program arr NL
         | program scan NL
         | program flen NL
         | program strval NL
         | program fcmp NL
         | program compar
         | program logic
         | program body 
         | program f 
         | program ifel
         | program for NL
         | program semicln NL
         | program while
         | program dowhile
         | program switch NL
         | program struct NL
         | program var NL
         | program print NL
         | program error NL { printf("\n### Line:%d ERROR ###\n", line-1); errflag=1; ge_check++;}
         | program szof NL 
         | program rt NL
         | program NL
         |
         ;

// Κανόνας για expressions
expr  : MEM_ADDR expr_helper {$$=$1;} {gc_check++;}
      | expr_helper PLUS expr_helper  { $$ = $1 + $3;} {gc_check++;}
      | expr_helper MINUS expr_helper  {$$ = $1 - $3;}{gc_check++;}
      | expr_helper DIV expr_helper  {$$ = $1 / $3;}{gc_check++;}
      | expr_helper MULT expr_helper  {$$ = $1 * $3;}{gc_check++;}
      | expr_helper MOD  expr_helper  {$$=$1 % $3; }{gc_check++;}
      | expr_helper EQUAL_MATH expr_helper semicln {$$ = $1;}{gc_check++;}
      | expr_helper ADD_ASSIGNMENT expr_helper semicln {$$ = $1 + $3;}{gc_check++;}
      | expr_helper SUB_ASSIGNMENT expr_helper semicln {$$ = $1 - $3;}{gc_check++;}
      | expr_helper MULT_ASSIGNMENT expr_helper semicln {$$ = $1 * $3;}{gc_check++;}
      | expr_helper DIV_ASSIGNMENT expr_helper semicln {$$ = $1 / $3;}{gc_check++;}
      | expr_helper INCREMENT semicln {$$ = ($1 + 1);}{gc_check++;}
      | expr_helper DECREMENT semicln {$$ = $1 - 1;}{gc_check++;}
      | MINUS expr_helper %prec NEG { $$=-$2; }{gc_check++;}
      ;

// Βοηθητικός κανόνας για expressions
expr_helper : number
            | var
            ;

// Κανόνας για semicolons
semicln  : SEMI
         ;        

// Κανόνας για αριθμούς int & floats
number: INTEGER {$$=atoi(yytext);} 
      | FLOAT {$$=atof(yytext);}
      ;

// Κανόνας για increment/decrement χωρίς ; για λούπες
loopdecinc  : number
            | var
            | loopdecinc INCREMENT {$$ = ($1 + 1);}
            | loopdecinc DECREMENT {$$ = $1 - 1;}
            ;

// Κανόνας συγκρίσεων
compar: compar_helper EQUAL_LOGIC compar_helper {$$ = ($1 == $3);}{gc_check++;}
      | compar_helper NOT_EQUAL_LOGIC compar_helper {$$ = ($1 != $3);} {gc_check++;}
      | compar_helper LESS_THAN compar_helper {$$ = ($1 < $3);}{gc_check++;}
      | compar_helper GREATER_THAN compar_helper {$$ = ($1 > $3);}{gc_check++;}
      | compar_helper LESS_EQ_THAN compar_helper {$$ = ($1 <= $3);}{gc_check++;}
      | compar_helper GREATER_EQ_THAN compar_helper {$$ = ($1 >= $3);}{gc_check++;}
      ;

//Βοηθητικός κανόνας συγκρίσεων
compar_helper     : number
                  | var
                  ;


// Κανόνας λογικών πράξεων          
logic : var 
      | number
      | NOT logic {$$ = !($1);}{gc_check++;}
      | logic AND logic {$$ = ($1 && $3);}{gc_check++;}
      | logic OR logic {$$ = $1 || $3;} {gc_check++;}  
      ; 
      
// Κανόνας για Identifiers
var   : IDENTIFIER  {$$=strdup(yylex);}
      |
      ;

// Κανώνας για τύπο δεδομένων
type  : TYPE_INT  {$$="TYPE_INT";}
      | TYPE_FL   {$$="TYPE_FL";}
      | CONST     {$$="CONST";}
      ;    

// Κανόνας για void
vtype : VOID {$$="VOID";}{gc_check++;}
      ;
      
// Κανόνας για δήλωση/ανάθεση τιμών
assign: type var semicln {printf("Declare");}{gc_check++;}
      | type var EQUAL_MATH number semicln {printf("Assign by declare");}{gc_check++;}
      ;  
       
// Κανόνας για πίνακες
arr   : OPEN_BRACKET arr_help_str CLOSE_BRACKET {printf("END OF ARRAY");} semicln {$$=$1;}{gc_check++;}
      | OPEN_BRACKET arr_help_int CLOSE_BRACKET {printf("END OF ARRAY");} semicln {$$=$1;}{gc_check++;}
      | OPEN_BRACKET arr_help_flt CLOSE_BRACKET {printf("END OF ARRAY");} semicln {$$=$1;}{gc_check++;}
      | var OPEN_BRACKET INTEGER CLOSE_BRACKET {printf("END OF ARRAY");} semicln {gc_check++;}
      ;

// Βοηθητικοί κανόνες για κάθε τύπο πίνακα
arr_help_str: STRING
            | STRING COMA arr_help_str
            ;

arr_help_int: INTEGER
            | INTEGER COMA arr_help_int
            ;

arr_help_flt: FLOAT
            | FLOAT COMA arr_help_flt
            ;

 
// Κανόνας για ανάθεση τιμών σε μεταβλητές
val   : var EQUAL_MATH number semicln {$$=$1; printf("Value assignment");}{gc_check++;}
      | var EQUAL_MATH var semicln    {$$=$1; printf("Value assignment form variable");}{gc_check++;}
      | var EQUAL_MATH expr  semicln  {$$=$1; printf("Value via operation");}{gc_check++;}
      | var COMA var EQUAL_MATH number COMA semicln {$$=$1; printf("Value assignment");}{gc_check++;}
      | var COMA var EQUAL_MATH arr COMA semicln {$$=$1; printf("Value assignment");}{gc_check++;}
      | var COMA var EQUAL_MATH STRING COMA  semicln {$$=$1; printf("Value assignment");}{gc_check++;}
      | var EQUAL_MATH arr {$$=$1; printf("Value assignment");}{gc_check++;}
      | var EQUAL_MATH f {$$=$1; printf("Function output assignment");}{gc_check++;}
      ;

// Ανάθεση συμβολοσειρών σε μεταβλητές
strval: STRING  {$$=strdup(yylex);} 
      | var EQUAL_MATH STRING semicln {$$=$1;}{gc_check++;}
      |
      ;

// Κανόνας για την συνάρτηση scan
scan  : SCAN OPEN_PAR var CLOSE_PAR semicln{gc_check++;}
      ;

// Κανόνας για την συνάρτηση len
flen  : LEN OPEN_PAR arr CLOSE_PAR semicln  {$$=$1; printf("Length");}{gc_check++;}
      | LEN OPEN_PAR STRING CLOSE_PAR semicln {$$=$1; printf("Length");} {gc_check++;}
      | LEN OPEN_PAR strval CLOSE_PAR semicln {$$=$1; printf("Length");}{gc_check++;}
      | LEN OPEN_PAR arr CLOSE_PAR  {$$=$1; printf("Length");}{gc_check++;}
      | LEN OPEN_PAR STRING CLOSE_PAR  {$$=$1; printf("Length");} {gc_check++;}
      | LEN OPEN_PAR strval CLOSE_PAR  {$$=$1; printf("Length");}{gc_check++;}
      ;

// Κανόνας για την συνάρτηση cmp
fcmp  : STRING {$$=strdup(yytext);}
      | CMP OPEN_PAR STRING COMA STRING CLOSE_PAR semicln { if( $1 == $2) printf("Compare") ;}{gc_check++;}
      | CMP OPEN_PAR strval COMA  strval  CLOSE_PAR semicln{gc_check++;}
      | CMP OPEN_PAR STRING COMA STRING CLOSE_PAR  { if( $1 == $2) printf("Compare") ;}{gc_check++;}
      | CMP OPEN_PAR strval COMA  strval  CLOSE_PAR {gc_check++;}
      ;

// Κανόνας για την συνάρτηση print. Καλείται ο κανόνας printhelper με του all
print : PRINT OPEN_PAR printhelper CLOSE_PAR semicln{gc_check++;}
      |
      ;
// Βοηθητικός κανόνας για χρήση στον κανόνα print
printhelper : var
            | var COMA printhelper
            | STRING
            | STRING COMA printhelper
            |
            ;

// Κανόνας για την συνάρτηση sizeof
szof :
     | SIZEOF OPEN_PAR var CLOSE_PAR SEMI {gc_check++;}
     | SIZEOF OPEN_PAR type CLOSE_PAR SEMI{gc_check++;}
     ;

// Βοηθητικός κανόνας για χρήση σε άλλους κανόνες
all   :
      | arr NL all 
      | val NL all
      | var NL all
      | scan
      | scan NL all
      | body NL all
      | flen NL all
      | fcmp NL all
      | assign NL all
      | expr NL all
      | compar NL all
      | logic NL all
      | semicln NL all
      | ifel
      | for NL all
      | while NL all
      | dowhile NL all
      | loopdecinc NL all
      | case NL all
      | switch NL all
      | NL all NL all
      | all NL NL all
      | struct NL all
      | type NL all
      | print all
      | f
      | f NL all
      | COMA 
      | arr 
      | val 
      | var 
      | body
      | flen 
      | fcmp 
      | assign 
      | expr 
      | compar 
      | logic 
      | semicln 
      | for 
      | while 
      | dowhile 
      | loopdecinc 
      | case 
      | switch 
      | switch all
      | switch all NL
      | NL all
      | all NL
      | struct 
      | type 
      | print 
      | COMA
      | NL 
      | printhelper
      | STRING
      | vtype
      | szof
      | rt
      | CONTINUE
      | comm NL all
      ; 

// Κανόνας για άνοιγμα/κλείσιμο σώματος {} συναρτήσεων
body  : OPEN_CBR all CLOSE_CBR
      | OPEN_CBR NL all CLOSE_CBR
      | OPEN_CBR all NL CLOSE_CBR
      | OPEN_CBR NL all NL CLOSE_CBR
      | onelinecode
      | NL onelinecode
      ;

// Βοηθητικός κανόνας του body σε περίπτωση που δεν έχει σώμα (μια γραμμή κώδικα)
onelinecode : 
      | arr 
      | val 
      | var 
      | flen 
      | fcmp 
      | assign 
      | expr 
      | compar 
      | logic 
      | ifel 
      | for 
      | while 
      | dowhile 
      | switch 
      | struct 
      | print 
      | szof
      | NL
      ; 


// Κανόνας func για δήλωση συναρτήσεων
f     : 
      | FUNC var OPEN_PAR type var COMA type var CLOSE_PAR {gc_check++;}{printf("END OF FUNCTION");}
      | FUNC var OPEN_PAR type var COMA type var CLOSE_PAR body {gc_check++;}{printf("END OF FUNCTION");}
      | FUNC vtype var OPEN_PAR type var COMA type var CLOSE_PAR {gc_check++;}{printf("END OF FUNCTION");}
      | FUNC vtype var OPEN_PAR type var COMA type var CLOSE_PAR body{gc_check++;}{printf("END OF FUNCTION");}
      | var OPEN_PAR var COMA var CLOSE_PAR semicln{gc_check++;}{printf("END OF FUNCTION");}
      | FUNC var OPEN_PAR CLOSE_PAR body{gc_check++;}{printf("END OF FUNCTION");}
      | f
      ;
      
// Κανόνας if...else
ifel  : IF OPEN_PAR compar CLOSE_PAR body{gc_check++;}{printf("END OF IF");}
      | IF OPEN_PAR logic CLOSE_PAR body{gc_check++;}{printf("END OF IF");}
      | IF OPEN_PAR compar CLOSE_PAR NL body{gc_check++;}{printf("END OF IF");}
      | IF OPEN_PAR logic CLOSE_PAR NL body{gc_check++;}{printf("END OF IF");}
      | IF OPEN_PAR compar CLOSE_PAR body NL ELSE IF body {gc_check++;}{printf("END OF IF...ELSE");}
      | IF OPEN_PAR logic CLOSE_PAR body NL ELSE IF body {gc_check++;}{printf("END OF IF...ELSE");}
      | IF OPEN_PAR compar CLOSE_PAR NL body NL ELSE IF body {gc_check++;}{printf("END OF IF...ELSE");}
      | IF OPEN_PAR logic CLOSE_PAR NL body NL ELSE IF body {gc_check++;}{printf("END OF IF...ELSE");}
      | IF OPEN_PAR compar CLOSE_PAR body NL ELSE body {gc_check++;}{printf("END OF IF...ELSE");}
      | IF OPEN_PAR logic CLOSE_PAR body NL ELSE body {gc_check++;}{printf("END OF IF...ELSE");}
      | IF OPEN_PAR compar CLOSE_PAR NL body NL ELSE body {gc_check++;}{printf("END OF IF...ELSE");}
      | IF OPEN_PAR logic CLOSE_PAR NL body NL ELSE body {gc_check++;}{printf("END OF IF...ELSE");}
      ;

// Κανόνας for
for   : FOR OPEN_PAR var EQUAL_MATH var semicln compar semicln loopdecinc CLOSE_PAR body{gc_check++;}{printf("END OF FOR");}
      | FOR OPEN_PAR var EQUAL_MATH var semicln compar semicln loopdecinc CLOSE_PAR NL body{gc_check++;}{printf("END OF FOR");}
      | FOR OPEN_PAR var EQUAL_MATH number semicln compar semicln loopdecinc CLOSE_PAR body{gc_check++;}{printf("END OF FOR");}
      | FOR OPEN_PAR var EQUAL_MATH number semicln compar semicln loopdecinc CLOSE_PAR NL body{gc_check++;}{printf("END OF FOR");}
      ;

// Κανόνας while
while : WHILE OPEN_PAR compar CLOSE_PAR body{gc_check++;}{printf("END OF WHILE");}
      | WHILE OPEN_PAR compar CLOSE_PAR NL body{gc_check++;}{printf("END OF WHILE");}
      | WHILE OPEN_PAR OPEN_PAR compar CLOSE_PAR whilehelper CLOSE_PAR body{gc_check++;}{printf("END OF WHILE");}
      | WHILE OPEN_PAR OPEN_PAR compar CLOSE_PAR whilehelper CLOSE_PAR NL body{gc_check++;}{printf("END OF WHILE");}
      ;

// Κανόνας do...while
dowhile     : DO body WHILE OPEN_PAR compar CLOSE_PAR semicln{gc_check++;}{printf("END OF DO...WHILE");}
            | DO body NL WHILE OPEN_PAR compar CLOSE_PAR semicln{gc_check++;}{printf("END OF DO...WHILE");}
            | DO body WHILE OPEN_PAR OPEN_PAR compar CLOSE_PAR whilehelper CLOSE_PAR semicln{gc_check++;}{printf("END OF DO...WHILE");}
            | DO body NL WHILE OPEN_PAR OPEN_PAR compar CLOSE_PAR whilehelper CLOSE_PAR semicln{gc_check++;}{printf("END OF DO...WHILE");}
            ;

// Βοηθητικός κανόνας για while & dowhile
whilehelper       : logic OPEN_PAR compar CLOSE_PAR
                  | logic OPEN_PAR compar CLOSE_PAR whilehelper
                  ;

// Βοηθητικός case για χρήση στον κανόνα switch
case  : CASE number COLON body BREAK semicln{gc_check++;}
      | CASE number COLON NL body BREAK semicln{gc_check++;}
      | CASE number COLON body NL BREAK semicln{gc_check++;}
      | CASE number COLON NL body NL BREAK semicln{gc_check++;}
      | CASE STRING COLON body BREAK semicln{gc_check++;}
      | CASE STRING COLON NL body BREAK semicln{gc_check++;}
      | CASE STRING COLON body NL BREAK semicln{gc_check++;}
      | CASE STRING COLON NL body NL BREAK semicln{gc_check++;}
      |
      ;

// Κανόνας switch. Καλείται η case μέσω του body -> all
switch: SWITCH OPEN_PAR var CLOSE_PAR body{gc_check++;}{printf("END OF SWITCH");}
      ;

// Κανόνας struct
struct: STRUCT var body semicln{gc_check++;}{printf("END OF STRUCT");}
      | 
      ;

// Κανόνας return
rt : RETURN number SEMI {gc_check++;}
   | RETURN var SEMI{gc_check++;}
   | RETURN expr SEMI{gc_check++;}
   | RETURN SEMI{gc_check++;}
   ;

// Κανόνας για τα σχόλια
comm  : COMMENT_LONG  { $$ = $1;}{gc_check++;}
      | COMMENT_SHORT {$$ = $1;}{gc_check++;}
      ;

%%

/* ____________________________________________________________________________
   Επιπρόσθετος κώδικας-χρήστη σε γλώσσα C. Στο σημείο αυτό μπορούν να 
   προστεθούν συναρτήσεις C που θα συμπεριληφθούν στον κώδικα του συντακτικού
   αναλυτή.
   ____________________________________________________________________________
*/
/* ____________________________________________________________________________
   Η συνάρτηση yyerror χρησιμοποιείται για την αναφορά σφαλμάτων. Συγκεκριμένα
   καλείται από την yyparse όταν υπάρξει κάποιο συντακτικό λάθος. Στην παρακάτω
   περίπτωση η συνάρτηση επί της ουσία δεν χρησιμοποιείται και απλώς επιστρέφει
   αμέσως
   ____________________________________________________________________________
*/

int yyerror(char *s)
{}

/* ____________________________________________________________________________
   Ο δείκτης yyin είναι αυτό που "δείχνει" στο αρχείο εισόδου. Εάν δεν γίνει
   χρήση του yyin, τότε η είσοδος γίνεται αποκλειστικά από το standard input
   ____________________________________________________________________________
*/

FILE *yyin;

/* ____________________________________________________________________________
  Η συνάρτηση main που αποτελεί και το σημείο εκκίνησης του προγράμματος.
  Γίνεται έλεγχος των ορισμάτων της γραμμής εντολών και κλήση της yyparse που
  πραγματοποιεί την συντακτική ανάλυση. Στο τέλος γίνεται έλεγχος για την
  επιτυχή ή μη έκβαση της ανάλυσης, καθώς και εκτύπωση των συντακτικά και
  λεκτικά σωστών/σφαλμάτων και αριθμός των whitespaces (κενά, tabs).
  _____________________________________________________________________________
*/

int main(int argc,char **argv)
{
	int i;
	if(argc == 2)
	      yyin=fopen(argv[1],"r");
	else
		yyin=stdin;

	int parse = yyparse();

	if (errflag==0 && parse==0) {    
		printf("\nINPUT FILE: PARSING SUCCEEDED.\n", parse);
            printf("\nLines of code: %d\n", line-1);
            printf("Lectical corrects: %d\n", lc_check);
            printf("Lectical errors: %d\n", le_check);
            printf("Grammatical corrects: %d\n", gc_check);
            printf("Grammatical erorrs: %d\n", ge_check);
            printf("Number of white spaces: %d\n", white_space);
      }   
	else {
		printf("\nINPUT FILE: PARSING FAILED.\n", parse);
            printf("\nLines of code: %d\n", line-1);
            printf("Lectical corrects: %d\n", lc_check);
            printf("Lectical errors: %d\n", le_check);
            printf("Grammatical corrects: %d\n", gc_check);
            printf("Grammatical erorrs: %d\n", ge_check);
            printf("Number of white spaces: %d\n", white_space);
      }
	return 0;
}
