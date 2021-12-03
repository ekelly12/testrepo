#include <iostream>
#include <unistd.h>

int main()
{
	sleep(0);
	void* failure = nullptr;
	sprintf((char*)failure,"%d",1);
	return 0;
}
