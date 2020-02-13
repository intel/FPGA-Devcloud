#include "HLS/hls.h"
#include "HLS/stdio.h"
#include <stdlib.h>
#include <assert.h>

// Function to find square root of x using binary search algorithm
// If x is not a perfect square, return floor of the square root
hls_avalon_slave_component
component unsigned int sqrt(hls_avalon_slave_register_argument unsigned int x)
{
    // Base cases
    if (x == 0 || x == 1)
       return x;

    // Do Binary Search for floor(sqrt(x))
    unsigned int start = 1, end = x, ans;
    # pragma max_concurrency 1
    while (start <= end)
    {
        unsigned int mid = (start + end) / 2;

        // If x is a perfect square
        if (mid*mid == x)
            return mid;

        // Since we need floor, we update answer when mid*mid is
        // smaller than x, and move closer to sqrt(x)
        if (mid*mid < x)
        {
            start = mid + 1;
            ans = mid;
        }
        else // If mid*mid is greater than x
            end = mid-1;
    }
    return ans;
}

int main(void)
{
	unsigned int x1 = 4;
        unsigned int x2 = 36;
	unsigned int x3 = 257;
	unsigned int x4 = 65536;
	printf("\n");
	// printf("x1: %d\n", x1);
	// printf("x2: %d\n", x2);
	// printf("x3: %d\n", x3);
	// printf("x4: %d\n", x4);
	printf("----------HLS COMPONENT----------\n");
	printf("floorsqrt(%d) = %d\n", x1, sqrt(x1));
	printf("floorsqrt(%d) = %d\n", x2, sqrt(x2));
	printf("floorsqrt(%d) = %d\n", x3, sqrt(x3));
	printf("floorsqrt(%d) = %d\n", x4, sqrt(x4));
	printf("---------------------------------\n");
	if(sqrt(x1) != 2){
		printf("floorsqrt(x1) is incorrect.\n");
	}
	if(sqrt(x2) != 6){
		printf("floorsqrt(x2) is incorrect.\n");
	}
	if(sqrt(x3) != 16){
		printf("floorsqrt(x3) is incorrect.\n");
	}
  if(sqrt(x4) != 256){
    printf("floorsqrt(x4) is incorrect.\n");
  }
	return 0;
}
