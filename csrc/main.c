#include <sys/ioctl.h>
#include <sys/types.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <threads.h>
#include <unistd.h>

#include "main.h"

#include "config.h"

void splitchar(char *str, const char *delimiter, char **tokens, int *count) {
  char *p;
  *count = 0;

  p = strtok(str, delimiter);
  while (p != NULL) {
      tokens[*count] = p;
      (*count)++;
      p = strtok(NULL, delimiter);
  }
}

char *getHomepath() {
  #if defined(_WIN32) || defined(_WIN64)
    #define HOMEENV "USERPROFILE"
    return *getenv(HOMEENV);
  #else
    #define HOMEENV "HOME"
    char *homeenv = getenv(HOMEENV);
    if (homeenv == NULL) {
      struct passwd *pwd = getpwuid(getuid());
      return pwd->pw_name;
    }
    return homeenv;
  #endif
}

// foreground 1 or background 0
static inline char *shellcolor(int ForB, const char *color, const char *shell) {
  static char retstr[512];
  if (strcmp(shell, "zsh") == 0) {
    switch (ForB) {
      case 0:
        snprintf(retstr+strlen(retstr), strlen(retstr), "%%{[38;5;%sm%%}", color);
      case 1:
        snprintf(retstr+strlen(retstr), strlen(retstr), "%%{[48;5;%sm%%}", color);
    }
  } else if (strcmp(shell, "bare")) {
    
  }
  return retstr;
}

static inline char *setcolor(const char *fg, const char *bg, const char *shell) {
  static char colorstr[1024];
  strcat(colorstr, shellcolor(0, bg, shell));
  strcat(colorstr, shellcolor(1, fg, shell));
  return colorstr;
}

int main(int argc, char *argv[]) {
  printf("%%{[38;5;250m%%}%%{[48;5;240m%%} %%n %%{[48;5;238m%%}%%{[38;5;240m%%}%%{[0m%%}%%{[38;5;250m%%}%%{[48;5;238m%%} %%m %%{[48;5;31m%%}%%{[38;5;238m%%}%%{[0m%%}%%{[38;5;15m%%}%%{[48;5;31m%%} ~ %%{[48;5;236m%%}%%{[38;5;31m%%}%%{[0m%%}%%{[38;5;15m%%}%%{[48;5;236m%%} %%# %%{[0m%%}%%{[38;5;236m%%}%%{[0m%%}");
  const char *shell_name = NULL;
  const char *dir_sep = splitDir;

  int promptType = 127;
  opterr = 0;

  for (int i = 0; i < argc; i++) {
    if (!(strncmp(argv[i], "-", 1) == 0)) {
      continue;
    }
    if (strcmp("-shell", argv[i]) == 0) {
      if (i+1 < argc) {
        if (strcmp(argv[i+1], "zsh")) {
          shell_name = "zsh";
        }
      }
    } else if (strcmp("-prompt", argv[i]) == 0) {
      promptType = 0;
    } else if (strcmp("-rprompt", argv[i]) == 0) {
      promptType = 1;
    } else if (strcmp("-prompt2", argv[i]) == 0) {
      promptType = 2;
    }
  }

  struct winsize w;
  ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);

  const char *username = getlogin();
  char hostname[512];
  int err = 0;
  err = gethostname(hostname, sizeof(hostname));
  if(err < 0) {
    printf("err");
    exit(-1);
  };
  char *cwd = getcwd(NULL, 0);
  char cwdbuf[8192];

  char *dirs[128];
  char *dirs2[128];
  int count;

  char *formatteddir[4096];

  char *homechar = getHomepath();
  const char hcbuf[BUFSIZ];
  int homedepth = 0;
  int inhome;
  inhome = strncmp(cwd, homechar, strlen(homechar));
  if (!inhome) {
    splitchar(homechar, dir_sep, dirs2, &homedepth);
  };
  splitchar(cwd, dir_sep, dirs, &count);
  int onceHome;
  onceHome = 0;
  for (int i = 0 + homedepth; i < count;i++) {
    if (onceHome) {
      sprintf(cwdbuf + strlen(cwdbuf), SEPARATOR " %s ", dirs[i]);
    } else {
      if (inhome) {
        strcat(cwdbuf, "/ ");
        sprintf(cwdbuf + strlen(cwdbuf), SEPARATOR" ");
      };
      strcat(cwdbuf, dirs[i]);
      strcat(cwdbuf, " ");
      onceHome = 1;
    }
  };
  if (count == 0) {
    strcat(cwdbuf, "/ ");
  };

  int userlen = strlen(username)+3;
  int hostlen = strlen(hostname)+3;
  int cwdlen = strlen(cwdbuf)+3;
  switch (promptType) {
    case 0:
      if (!inhome && count != homedepth) {
        printf("%s", setcolor(USER_FG, USER_BG, shell_name));
        printf("   ");
        /*printf(FG USER_FG BG USER_BG " %s "RESET_ALL FG USER_BG BG HOST_BG PL_SYMBOL RESET_ALL
          FG HOST_FG BG HOST_BG" %s " RESET_ALL FG HOST_BG BG HOME_BG PL_SYMBOL RESET_ALL
          FG HOME_FG BG HOME_BG" ~ " RESET_ALL FG HOME_BG BG PATH_BG PL_SYMBOL RESET_ALL
          FG CWD_FG BG PATH_BG" %s" RESET_ALL FG PATH_BG PL_SYMBOL,username, hostname, cwdbuf);*/
      } else if (!inhome) {
        printf(FG USER_FG BG USER_BG" %s "RESET_ALL FG USER_BG BG HOST_BG PL_SYMBOL RESET_ALL
          FG HOST_FG BG HOST_BG" %s " RESET_ALL FG HOST_BG BG HOME_BG PL_SYMBOL RESET_ALL
          FG HOME_FG BG HOME_BG" ~ " RESET_ALL FG HOME_BG PL_SYMBOL RESET_ALL,username, hostname);
      } else {
          printf(FG USER_FG BG USER_BG" %s "RESET_ALL FG USER_BG BG HOST_BG PL_SYMBOL RESET_ALL
          FG HOST_FG BG HOST_BG" %s " RESET_ALL FG HOST_BG BG PATH_BG PL_SYMBOL RESET_ALL
          FG CWD_FG BG PATH_BG" %s" RESET_ALL FG PATH_BG PL_SYMBOL,username, hostname, cwdbuf);
      };
      break;
    case 2:
      printf(FG CMD_PASSED_FG BG CMD_PASSED_BG "  $ " RESET_ALL FG CMD_PASSED_BG PL_SYMBOL RESET_ALL);
      break;
  }
  printf(" ");
  return 0;
}
