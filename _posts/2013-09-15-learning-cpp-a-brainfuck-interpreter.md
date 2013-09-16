---
layout: post
title: 'Learning C++: A brainfuck Interpreter'
---

As I try to steer my career away from generic application building and into
scientific computing, I find myself wanting to learn C++. This is an odd
admission for a Rubyist, as I usually see movement in the opposite direction,
with tired C programmers washing up on the sweet shores of Ruby, sighing, with
relief, that it just feels so right.

However, with myself it's another story. I've spent almost my entire career
writing in only scripting languages. I've had a touch of Java, but nothing
to brag about. I first found myself writing some C++ by way of Objective C++
while I worked on [SUPER SECRET PROJECT] during Big Nerd Ranch's [Clash of the
Coders 2013][1]. It didn't take me long to figure out how to be effective with
the language, but I'm sure I abused all kinds of things.

With less than a tenuous grasp on pointers and references, the mysteries of
debugging the effects of uninitialized variables, the weird constructor syntax,
and being amazed that I could do things like iterate over a few million pixels
in a matrix, we finally banged out a working project and grabbed third place.

So, in an effort to go back and learn the things I just smashed through
previously, I've started working on a few little C++ projects. One that I
thought would be appropriate for learning how to use pointers is a
[brainfuck][2] interpreter. If you aren't in the know, brainfuck is a tiny
language with only eight instructions:

* `>` Move the pointer to the right
* `<` Move the pointer to the left
* `+` Increment the memory cell under the pointer
* `-` Decrement the memory cell under the pointer
* `.` Output the character signified by the cell at the pointer
* `,` Input a character and store it in the cell at the pointer
* `[` Jump past the matching ] if the cell under the pointer is 0
* `]` Jump back to the matching [ if the cell under the pointer is nonzero

```brainfuck
>+++++++++[<++++++++>-]<.>+++++++[<++++>-]<+.+++++++..+++.>>>++++++++[<++++>-]
<.>>>++++++++++[<+++++++++>-]<---.<<<<.+++.------.--------.>>+.
```
Hello, World!

# First, just make it work

My approach to implementing the interpreter was to first write it as it made
sense to my scripting-brain: the memory would be an array of `char`s, the
pointer would just be an `int` to index into that array and, the program and
current execution index would have similar mechanics.

That resulted in code that looked like this:

```cpp
void pincr() {
  ++d;
}

void pdecr() {
  --d;
}

void bincr() {
  ++data[d];
}

void bdecr() {
  --data[d];
}

void puts() {
  std::cout << data[d];
}

void gets() {
  std::cin >> data[d];
}
```

My solution for the `[]` loop instructions were very rudimentary at first,
capable of handling "Hello, World!", but not anything with nested loops. This
is because I just naïvely skipped back and forth to the next bracket for each
instruction.

I finally worked out a decent solution that skips to the matching bracket:

```cpp
void bropen() {
  int bal = 1;
  if (data[d] == '\0') {
    do {
      p++;
      if      (program[p] == '[') bal++;
      else if (program[p] == ']') bal--;
    } while ( bal != 0 );
  }
}

void brclose() {
  int bal = 0;
  do {
    if      (program[p] == '[') bal++;
    else if (program[p] == ']') bal--;
    p--;
  } while ( bal != 0 );
}
```

At this point, it was time to replace my data and program `int` indices.

# Pointers away!

The trickiest part for me wasn't handling the instructions, but setting up the
pointers to begin with. From reading [Learning C++ Pointers for REAL
Dummies][3], I knew that if I had a pointer `p`, that `*p` meant "the value of
the thing p is pointing at."

An array is just a `const` pointer to the first cell in the array, so if I declare
a pointer `d` (for data), and point it at the first cell of `data`...

```cpp
char data[30000];
char *d;
d = data;
```

Follow the same pattern for program and its pointer, `p`, and all that's left
to do is update the implementation of the instructions. Instead of incrementing
the `int` indices, I just need to increment the corresponding pointers, and instead
of accessing the arrays using the indices, I just need to access the value that the
pointers point to.

```cpp
#include <iostream>

class Brainfuck {
  public:
    char data[30000];
    char *d;
    const char *p;

    Brainfuck(const char prog[]) {
      d = data;
      p = prog;
    }

    void pincr() {
      d++;
    }

    void pdecr() {
      d--;
    }

    void bincr() {
      (*d)++;
    }

    void bdecr() {
      (*d)--;
    }

    void puts() {
      std::cout << *d;
    }

    void gets() {
      char input;
      std::cin >> input;
    }

    void bropen() {
      int bal = 1;
      if (*d == '\0') {
        do {
          p++;
          if      (*p == '[') bal++;
          else if (*p == ']') bal--;
        } while ( bal != 0 );
      }
    }

    void brclose() {
      int bal = 0;
      do {
        if      (*p == '[') bal++;
        else if (*p == ']') bal--;
        p--;
      } while ( bal != 0 );
    }

    void evaluate() {
      while (*p) {
        switch (*p) {
          case '>':
            pincr();
            break;
          case '<':
            pdecr();
            break;
          case '+':
            bincr();
            break;
          case '-':
            bdecr();
            break;
          case '.':
            puts();
            break;
          case ',':
            gets();
            break;
          case '[':
            bropen();
            break;
          case ']':
            brclose();
            break;
        }
        p++;
      }
    }
};
```

And there we have it. A working brainfuck interpreter, capable of executing [99
Bottles of Beer][4] in about 0.03 seconds. I'm still not happy with the loop
implementation. I know I shouldn't have to incrementally rewind to the opening
bracket for each iteration, and next I'm going to work on achieving it using
the `std::stack`.

[1]: http://blog.bignerdranch.com/2650-clash-of-the-coders-2013/
[2]: http://esolangs.org/wiki/Brainfuck
[3]: http://alumni.cs.ucr.edu/~pdiloren/C++_Pointers/index.htm
[4]: http://esoteric.sange.fi/brainfuck/bf-source/prog/BOTTLES.BF
