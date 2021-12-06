#include <iostream>
#include <exception>
using namespace std;

int main () {
  try
  {
    int* myarray = nullptr;
	*myarray = 4;
  }
  catch (exception& e)
  {
    cout << "Standard exception: " << e.what() << endl;
  }
  return 0;
}
