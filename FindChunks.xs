#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <wavestats.h>

typedef char void_char;

MODULE = Audio::FindChunks		PACKAGE = Audio::FindChunks
PROTOTYPES: ENABLE

long
bool_find_runs(input, output, cnt, out_cnt)
	int *	input
	array_run_t *	output
	long	cnt
	long	out_cnt

void
double_find_above(input, output, cnt, threshold)
	double *	input
	int *	output
	long	cnt
	double	threshold

void
double_median3(rmsarray, medarray, total_blocks)
	double *	rmsarray
	double *	medarray
	long	total_blocks

void
double_sort(input, output, cnt)
	double *	input
	double *	output
	long	cnt

double
double_sum(input, off, cnt);
	double *	input
	long	off
	long	cnt

void
int_find_above(input, output, cnt, threshold)
	int *	input
	int *	output
	long	cnt
	int	threshold

void
int_sum_window(input, output, cnt, window_size)
	int *	input
	int *	output
	long	cnt
	int	window_size

void
le_short_sample_stats(buf, stride, samples, stat)
	void_char *	buf
	int	stride
	long	samples
	array_stats_t *	stat
