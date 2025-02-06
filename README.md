# EBNFPlus
# An app that compiles itself, but also maps any input to output using EBNF and functional expressions

EBNFPlus is a computer language specifically suited for mapping input to output by a  combination of syntax and semantic rules. The syntax rules are in Extended BNF embedded with semantic expressions. At execution, input is checked against the syntax rules which control the semantic expressions to generate output.

For example consider an input of 5 characters "Hello". Such string conforms to the syntax:

	rule = "Hello";
 
If we want to respond to this specific data we can extend above rule with some actions:

	rule = "Hello", pOut(“Hey! How are you?”);
 
which simply says if  "Hello" is encountered then the EBNFPlus function pOut will output “Hey! How are you?”.  In case something else is encountered nothing is generated and the rule is returned false to the caller. The used comma in this rule is the concatenation syntax element (read and) that indicates to continue the evaluation of the rule although it is here followed by a function. In other words, EBNFPlus just extends the Extended BNF with semantic expressions. Hence, the plus sign in its name.

If we like to respond to an alternative content, say "Hallo" (Dutch for “Hello”) then a syntax rule to cover also the alternative is:

	rule = "Hello"| "Hallo";
 
where the bar ("|”) is read as or.

Mapping the alternatives to separate output can be expressed as:

	rule =	"Hello", pOut(“Hey! How are you?”)       |
 
		“Hallo", pOut(“He! Hoe gaat het met je?”);
  
Exception handling becomes obvious:

	rule =	"Hello", pOut(“Hey hello! How are you?”) |
 
		"Hallo", pOut(“He! Hoe gaat het met je?”)|
  
		{b},	 pOut(“Scusi, non ho capito!”)   ;
  
Here {b}, flushes all input and the system will generate the remark it did not understand the input.

EBNFplus supports the standard syntax elements, while the semantic can be expressed by EBNFPlus functions including the host language, that is the language to which EBNFPlus sources are cross compiled to (e.g. x64 assembly in the current version, but GO and VBA versions also exist).

The EBNFplus helps solutions for a large class of mapping chalenges from simple to complex. Typical applications include translators (such as between Infix and Postfix expressions, hex tables and binary formats, IFSF binary payment protocols to man-readable formats), filters (e.g. for finding telephone numbers, email addresses, card iso numbers), converters (e.g. between data sets in CSV, XML, Json and Yaml), interfaces  (e.g. Web/API servers and clients), and compilers (e.g. is itself! EBNFPlus to assembly).

## Examples
An ISO8583 interpreter that converst biniary to json file: https://github.com/katewinebrewer/8583-bin-to-json-convertor
