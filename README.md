pslogger
========

A package for asynchronous db-based logging in the Oracle-based PeopleSoft installations. 

Installation
============
1. run the sql in the target database
2. Create Application Packages - manually based on the folder structure found in src/peoplecode/APPLICATION_PACKAGE

   for instance: 
        a. Create Application Package UTILTITIES 
        b. Create Application Class - TextUtils and add the code found in TextUtils.OnExecute.peoplecode

        a. Create Application Package - LOGGER
        b. Create Application Class - BaseDBLogger and add the code found in BaseDBLogger.OnExecute.peoplecode
        c. Repeat for all the other files from that folder 

        Note: UTILITIES package and classes must be created first 
              In The LOGGER pcakage BaseDBLogger must be created before any other class 

              This is to avoid app designer save errors

Usage
=====

TBA
