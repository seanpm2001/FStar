/* 
  This file was generated by KaRaMeL <https://github.com/FStarLang/karamel>
 */
#include "krml/internal/compat.h"
#include "krmllib.h"
#ifndef __LowParseWriters_Test_H
#define __LowParseWriters_Test_H

#include "LowStar.h"


typedef struct LowParseWriters_rptr_s
{
  uint8_t *rptr_base;
  uint32_t rptr_len;
}
LowParseWriters_rptr;

#define LowParseWriters_Correct 0
#define LowParseWriters_Error 1

typedef uint8_t LowParseWriters_result__bool_tags;

typedef struct LowParseWriters_result__bool_s
{
  LowParseWriters_result__bool_tags tag;
  union {
    bool case_Correct;
    Prims_string case_Error;
  }
  ;
}
LowParseWriters_result__bool;

LowParseWriters_result__bool LowParseWriters_Test_test_read();

LowParseWriters_result__bool LowParseWriters_Test_test_read_if_1();

typedef struct LowParseWriters_result__uint32_t_s
{
  LowParseWriters_result__bool_tags tag;
  union {
    uint32_t case_Correct;
    Prims_string case_Error;
  }
  ;
}
LowParseWriters_result__uint32_t;

LowParseWriters_result__uint32_t
LowParseWriters_Test_test_read_from_ptr(LowParseWriters_rptr b);

LowParseWriters_result__uint32_t
LowParseWriters_Test_test_read_if_nontrivial(LowParseWriters_rptr b);

LowParseWriters_result__uint32_t
LowParseWriters_Test_test_read_if_really_nontrivial(
  LowParseWriters_rptr b,
  LowParseWriters_rptr c
);

#define LowParseWriters_ICorrect 0
#define LowParseWriters_IError 1
#define LowParseWriters_IOverflow 2

typedef uint8_t LowParseWriters_iresult_____tags;

typedef struct LowParseWriters_iresult_____s
{
  LowParseWriters_iresult_____tags tag;
  union {
    uint32_t case_ICorrect;
    Prims_string case_IError;
  }
  ;
}
LowParseWriters_iresult____;

LowParseWriters_iresult____
LowParseWriters_Test_extract_write_two_ints_1(
  uint32_t x,
  uint32_t y,
  uint8_t *buf,
  uint32_t len,
  uint32_t pos
);

LowParseWriters_iresult____
LowParseWriters_Test_extract_write_two_ints_2(
  uint32_t x,
  uint32_t y,
  uint8_t *buf,
  uint32_t len,
  uint32_t pos
);

LowParseWriters_iresult____
LowParseWriters_Test_extract_write_two_ints_ifthenelse_2_aux(
  uint32_t x,
  uint32_t y,
  uint8_t *buf,
  uint32_t len,
  uint32_t pos
);

typedef struct LowParseWriters_Test_example_s
{
  uint32_t left;
  uint32_t right;
}
LowParseWriters_Test_example;

uint32_t
LowParseWriters_Test___proj__Mkexample__item__left(LowParseWriters_Test_example projectee);

uint32_t
LowParseWriters_Test___proj__Mkexample__item__right(LowParseWriters_Test_example projectee);

typedef struct K___uint32_t_uint32_t_s
{
  uint32_t fst;
  uint32_t snd;
}
K___uint32_t_uint32_t;

LowParseWriters_Test_example
LowParseWriters_Test_synth_example(K___uint32_t_uint32_t uu____6435);

K___uint32_t_uint32_t LowParseWriters_Test_synth_example_recip(LowParseWriters_Test_example e);

LowParseWriters_iresult____
LowParseWriters_Test_extract_write_example(
  uint32_t left,
  uint32_t right,
  uint8_t *buf,
  uint32_t len,
  uint32_t pos
);

LowParseWriters_iresult____
LowParseWriters_Test_extract_write_two_ints(
  uint32_t left,
  uint32_t right,
  uint8_t *buf,
  uint32_t len,
  uint32_t pos
);

#define __LowParseWriters_Test_H_DEFINED
#endif
