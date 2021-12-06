#include <iostream>
#include <exception>
using namespace std;

int main () 
{
	throw std::runtime_error("error");
	return 0;
}
