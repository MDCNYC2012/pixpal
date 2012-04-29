#!/usr/bin/python
# -*- coding: utf-8 -*-

from django.shortcuts import render_to_response
from django.utils import simplejson
from django.http import HttpResponse

from string import Template
from datetime import datetime

import MySQLdb
import os
import glob
import sys
import csv
import array

MAX_X = 100
MAX_Y = 100


def open_db():
    con = MySQLdb.connect(host="localhost", user="aa", passwd="aa", db="aa")

    with con:
        cur = con.cursor()
        cur.execute('SELECT count(*) from pixels;')
        row = cur.fetchone()
        print "Number of rown in PIXELS table: ", row[0]
        return con
        

def get_char_pixels_from_db (con):
    with con:
        res = array.array('c', ['0'] * ((MAX_X+1) * (MAX_Y+1) + 2) )
        res[0] = chr(MAX_X+1)
        res[1] = chr(MAX_Y+1)

        cur = con.cursor()
        cur.execute('SELECT pixel FROM pixels ORDER BY id;')
        rows = cur.fetchall()
        for i, row in enumerate(rows):
            res[i + 2] = chr(row[0])
        
        return res

def get_text_pixels_from_db (con):
    with con:
        res = []
        res.append(MAX_X+1)
        res.append(MAX_Y+1)

        cur = con.cursor()
        cur.execute('SELECT pixel FROM pixels ORDER BY id;')
        rows = cur.fetchall()
        for i, row in enumerate(rows):
            res.append(row[0])
        
        return res


def set_pixel_to_db (con, x, y, pixel):
    with con:
        cur = con.cursor()
        cur.execute(Template("UPDATE pixels SET pixel = $pixel WHERE x = $x AND y = $y").substitute({ 'pixel' : pixel, 'x' : x, 'y' : y }))
    

def get_pixels(request):
#    try:
        req_format = "0"
        if request.method == 'GET':
            req_format = request.GET.get('format')
            print "format", req_format
            
        response = ""
        
        con = open_db()
        with con:
            if req_format == "1":
                pixels = get_char_pixels_from_db(con)
                response = HttpResponse(pixels, content_type='application/octet-stream')
                print "sending application/octet-stream"
            else:
                pixels = get_text_pixels_from_db(con)
                response = HttpResponse(pixels, content_type='text/plain')
                print "sending text/plain"
                
#        response['Content-Length'] = (MAX_X+1) * (MAX_Y+1) + 2
        
        return response

#    except:
#        import traceback
#        txt=traceback.format_exc()
#        print txt


def set_pixel(request):
    x = -1
    y = -1
    pixel = -1

    if request.method == 'GET':
        try:
            x = int(request.GET.get('x'))
            y = int(request.GET.get('y'))
            pixel = int(request.GET.get('pixel'))
            print x, y, pixel

            if MAX_X >= x >= 0 and MAX_Y >= y >= 0 and 255 >= pixel >= 0:
                con = open_db()
                with con:
                    set_pixel_to_db(con, x, y, pixel)
        except:
            print "get_pixel returned an error! Probably can't convert x, y or pixel parameter to int"
    
            
    return get_pixels(request)
