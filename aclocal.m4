#
# $Id: aclocal.m4,v 1.1 2002/01/24 08:54:43 dupuy Exp $
#
# ++Copyright LIBBK++
#
# Copyright (c) 2002 The Authors.  All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Mail <projectbaka@baka.org> for further information
#
# --Copyright LIBBK--
#
# autoconf m4 macros
#

#
# Gnu compilers use ((__constructor__)) and ((__destructor__)) __attributes__
# to indicate that a function is a "static constructor" and should be called at
# load time.  Solaris uses #pragma init(fn).  Other systems may use other
# techniques, or we can just fall back on libtool's ltdl support to call it
# ourselves.
#
# AC_CONSTRUCTORS
# ---------------
AC_DEFUN([AC_CONSTRUCTORS],
[AC_CACHE_CHECK(for constructor attribute, ac_cv_have_constructor_attribute,
 [AC_TRY_RUN([
   static int x = 1;
   __attribute__((__constructor__)) reset() { x = 0; }
   int main() { return x; }],
        ac_cv_have_constructor_attribute=yes,
        ac_cv_have_constructor_attribute=no,
  [AC_TRY_COMPILE([void __attribute__((__constructor__))foo(void);], ,
        ac_cv_have_constructor_attribute=yes,
        ac_cv_have_constructor_attribute=no)
  ])
 ])
 if test $ac_cv_have_constructor_attribute = yes; then
  AC_DEFINE(HAVE_CONSTRUCTOR_ATTRIBUTE)
 else
  AC_CACHE_CHECK(for pragma init(x) support, ac_cv_have_init_pragma,
  [AC_TRY_RUN([
    static int x = 1;
    #pragma init(reset)
    reset() { x = 0; } int main() { return x; }],
        ac_cv_have_init_pragma=yes,
        ac_cv_have_init_pragma=no,
   [AC_TRY_COMPILE([
     #pragma init(foo)
     ], ,
        ac_cv_have_init_pragma=yes,
        ac_cv_have_init_pragma=no)
   ])
  ])
  if test $ac_cv_have_init_pragma = yes; then
   AC_DEFINE(HAVE_INIT_PRAGMA)
  fi
 fi
])# AC_CONSTRUCTORS


# AC_FUNC_INET_PTON
# ----------------
AC_DEFUN([AC_FUNC_INET_PTON],
[AC_CHECK_FUNCS(inet_pton, [],
[# inet_pton is in -lnsl on Solaris
AC_CHECK_LIB(nsl, inet_pton,
             [AC_DEFINE(HAVE_INET_PTON)
LIBS="-lnsl $LIBS"])])dnl
])# AC_FUNC_INET_PTON

#
# BSD-based systems have an sa_len field in struct sockaddr that may need to
# be maintained.  Other systems do not have this, and must use the sa_family
# field (and possibly other structure types and fields) to figure it out.  On
# some systems, the lookup on sa_family can be accessed via the SA_LEN macro.
#
# AC_SA_LEN
# ---------
AC_DEFUN([AC_SA_LEN],
[AC_CACHE_CHECK(whether struct sockaddr has sa_len, ac_cv_have_sockaddr_sa_len,
 [AC_TRY_COMPILE([
   #include <sys/types.h>
   #include <sys/socket.h>],[
   extern struct sockaddr *ps; return ps->sa_len;],
        ac_cv_have_sockaddr_sa_len=yes,
        ac_cv_have_sockaddr_sa_len=no)
 ])
 if test $ac_cv_have_sockaddr_sa_len = yes; then
  AC_DEFINE(HAVE_SOCKADDR_SA_LEN)
 else
  AC_CACHE_CHECK(for SA_LEN macro, ac_cv_have_sa_len_macro,
  [AC_TRY_COMPILE([
    #include <sys/types.h>
    #include <sys/socket.h>],[
    extern struct sockaddr *ps;
    #ifndef SA_LEN
    #error SA_LEN is not a macro
    #endif
    return SA_LEN(ps);],
        ac_cv_have_sa_len_macro=yes,
        ac_cv_have_sa_len_macro=no)
  ])
  if test $ac_cv_have_sa_len_macro = yes; then
   AC_DEFINE(HAVE_SA_LEN_MACRO)
  fi
 fi
])# AC_SA_LEN
