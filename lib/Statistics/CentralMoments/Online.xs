#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdlib.h>
#include <math.h>
#include "ppport.h"

typedef struct scmo {
  unsigned int count;
  double mean;
  double m2;
  double m3;
  double m4;
} scmo_t;



MODULE = Statistics::CentralMoments::Online PACKAGE = Statistics::CentralMoments::Online

PROTOTYPES: DISABLE

REQUIRE: 2.21

scmo_t *
scmo_t::new()
  PREINIT:
  CODE:
    RETVAL = malloc(sizeof(scmo_t));
    if (RETVAL == NULL)
      croak("Out of memory");

    RETVAL->count = 0;
    RETVAL->mean = 0.;
    RETVAL->m2 = 0.;
    RETVAL->m3 = 0.;
    RETVAL->m4 = 0.;
  OUTPUT: RETVAL

void
scmo_t::DESTROY()
  CODE:
    free(THIS);

unsigned int
scmo_t::get_count()
  CODE:
    RETVAL = THIS->count;
  OUTPUT: RETVAL

double
scmo_t::get_mean()
  CODE:
    RETVAL = THIS->mean;
  OUTPUT: RETVAL

SV *
scmo_t::get_moments()
  PREINIT:
    AV *av;
  CODE:
    av = newAV();
    RETVAL = newRV_noinc((SV *)av);
    av_extend(av, 4);
    av_store(av, 0, newSVuv(THIS->count));
    av_store(av, 1, newSVnv(THIS->mean));
    av_store(av, 2, newSVnv(THIS->m2));
    av_store(av, 3, newSVnv(THIS->m3));
    av_store(av, 4, newSVnv(THIS->m4));
  OUTPUT: RETVAL

double
scmo_t::get_variance()
  CODE:
    RETVAL = 0.;
    if (THIS->count >= 2)
      RETVAL = THIS->m2 / ((double)THIS->count - 1);
  OUTPUT: RETVAL

double
scmo_t::get_skewness()
  CODE:
    RETVAL = sqrt((double)THIS->count) * THIS->m3 * pow(THIS->m2, 1.5);
  OUTPUT: RETVAL

double
scmo_t::get_kurtosis()
  CODE:
    RETVAL = (double)THIS->count * THIS->m4 / (THIS->m2 * THIS->m2) - 3;
  OUTPUT: RETVAL


void
scmo_t::add_data(AV *data_av)
  PREINIT:
    unsigned int i;
    unsigned int n;
    SV **svp;
    unsigned int count;
    double mean, m2, m3, m4;
  INIT:
    count = THIS->count;
    mean = THIS->mean;
    m2 = THIS->m2;
    m3 = THIS->m3;
    m4 = THIS->m4;
  CODE:
    /* http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
     * uses Terriberry's formulas */
    n = av_len(data_av) + 1;
    for (i = 0; i < n; ++i) {
      svp = av_fetch(data_av, i, 0);
      if (svp != NULL) {
        const double delta = SvNV(*svp) - mean;
        const double delta_n = delta / (double)(count + 1);
        const double delta_n_sq = delta_n * delta_n;
        const double delta_sq_n_n1 = delta * delta_n * count;

        ++count;
        mean += delta_n;
        m4 += delta_sq_n_n1 * delta_n_sq * (double)(count * count - 3. * count + 3.) + 6. * delta_n_sq * m2 - 4. * delta_n * m3;
        m3 += delta_sq_n_n1 * delta_n * (double)(count - 2) - 3. * delta_n * m2;
        m2 += delta_sq_n_n1;
      }
    }
    THIS->count = count;
    THIS->mean = mean;
    THIS->m2 = m2;
    THIS->m3 = m3;
    THIS->m4 = m4;



void
scmo_t::merge(scmo_t *other)
  CODE:
    {
      const unsigned int count_a = THIS->count;
      const double mean_a = THIS->mean;
      const double m2_a = THIS->m2;
      const double m3_a = THIS->m3;
      const double m4_a = THIS->m4;

      const unsigned int count_b = other->count;
      const double mean_b = other->mean;
      const double m2_b = other->m2;
      const double m3_b = other->m3;
      const double m4_b = other->m4;
      const double delta = mean_b - mean_a;

      const unsigned int count = count_a + count_b;
      THIS->count = count;

      const double delta_sq = delta * delta;
      THIS->mean = (count_a * mean_a + count_b * mean_b) / (double)count;
      const double count_a_b = count_a * count_b;
      const double count_a_sq = count_a * count_a;
      const double count_b_sq = count_b * count_b;
      const double count_sq = count * count;
      THIS->m2 = m2_a + m2_b + delta_sq * ((double)count_a_b / (double)count);

      THIS->m3 = m3_a + m3_b +
                 delta_sq * delta * ((double)(count_a_b * (count_a - count_b)) / (double)count_sq) +
                 3. * delta * ((count_a * m2_b - count_b * m2_a) / (double)count);
      THIS->m4 = m4_a + m4_b +
                 delta_sq * delta_sq *
                 ((double)count_a_b * (double)(count_a_sq - count_a_b + count_b_sq) /
                    (double)(count_sq * count)) +
                 6. * delta_sq * ((count_a_sq * m2_b + count_b_sq * m2_a) / (double)count_sq) +
                 4. * delta * ((count_a * m3_b - count_b * m3_a) / (double)count);
    }
