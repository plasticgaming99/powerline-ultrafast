#define RESET_ALL "\x1b[0m"

#define FG "\x1b[38;5;"
#define BG "\x1b[48;5;"

#define getpath

#ifdef _WIN32
    #define splitDir "\";
#elif _WIN64
    #define splitDir "\";
#else
    #define splitDir "/";
#endif