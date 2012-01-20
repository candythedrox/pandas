cimport numpy as cnp
cimport cython
cimport cpython
import numpy as np

from numpy cimport int64_t, import_array

# this is our datetime.pxd
from datetime cimport *

# import datetime C API
PyDateTime_IMPORT

# initialize numpy
import_array()

cdef class Date:
    cdef:
        int64_t timestamp
        object freq
        object tzinfo

    def __init__(self, int64_t ts, object freq = None, object tzinfo = None):
        self.timestamp = ts
        self.freq = freq
        self.tzinfo = tzinfo

    # --- the following properties to make it compatible with datetime

    cdef npy_datetimestruct decompose(self):
        cdef npy_datetimestruct dts
        PyArray_DatetimeToDatetimeStruct(self.timestamp, NPY_FR_us, &dts)
        return dts

    property year:
        def __get__(self):
            return self.decompose().year

    property month:
        def __get__(self):
            return self.decompose().month

    property day:
        def __get__(self):
            return self.decompose().day

    property hour:
        def __get__(self):
            return self.decompose().hour

    property minute:
        def __get__(self):
            return self.decompose().min

    property second:
        def __get__(self):
            return self.decompose().sec

    property microsecond:
        def __get__(self):
            return self.decompose().us


# TODO: this is wrong calculation, wtf is going on
def datetime_to_datetime64_WRONG(object boxed):
    cdef int64_t y, M, d, h, m, s, u
    cdef npy_datetimestruct dts

    if PyDateTime_Check(boxed):
        dts.year = PyDateTime_GET_YEAR(boxed)
        dts.month = PyDateTime_GET_MONTH(boxed)
        dts.day = PyDateTime_GET_DAY(boxed)
        dts.hour = PyDateTime_TIME_GET_HOUR(boxed)
        dts.min = PyDateTime_TIME_GET_MINUTE(boxed)
        dts.sec = PyDateTime_TIME_GET_SECOND(boxed)
        dts.us = PyDateTime_TIME_GET_MICROSECOND(boxed)
        dts.ps = 0
        dts.as = 0

        return PyArray_DatetimeStructToDatetime(NPY_FR_us, &dts)

def from_datetime(object dt, object freq=None):
    cdef int64_t converted

    if PyDateTime_Check(dt):
        converted = np.datetime64(dt).view('i8')
        return Date(converted, freq, dt.tzinfo)

    raise ValueError("Expected a datetime, received a %s" % type(dt))

