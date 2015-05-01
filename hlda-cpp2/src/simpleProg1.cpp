#include <string> 
using namespace std;

string answerQuestion(string q)
{
	string a;
	if(q == "Please?") {
		a = "Okay!";
	}
	else {
		a = "You forgot the magic word!";
	}
	return a;
}