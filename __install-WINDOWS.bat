@echo off

ECHO.
ECHO.

ECHO. ================================================================================
ECHO. DATA
ECHO. ================================================================================

rem Rscript -e "setwd('data-raw'); example(source); sourceDir('.')"
rem if %ERRORLEVEL% GEQ 1 PAUSE

ECHO.
ECHO.
ECHO.
ECHO.
ECHO.
ECHO.
ECHO.


ECHO. ================================================================================
ECHO. DOCUMENT
ECHO. ================================================================================

Rscript -e "devtools::document()"
if %ERRORLEVEL% GEQ 1 PAUSE

ECHO.
ECHO.
ECHO.
ECHO.
ECHO.
ECHO.
ECHO.


ECHO. ================================================================================
ECHO. INSTALL
ECHO. ================================================================================

Rscript -e "devtools::install(build = TRUE, build_vignettes = TRUE, upgrade = 'never')"
if %ERRORLEVEL% GEQ 1 PAUSE

ECHO.
ECHO.
ECHO.
ECHO.
ECHO.
ECHO.
ECHO.


ECHO. ================================================================================
ECHO. TESTS
ECHO. ================================================================================


ECHO.
ECHO. Testthat
ECHO. --------------------------------------------------------------------------------

Rscript -e "testthat::test_package('FPEMglobal.aux')"
if %ERRORLEVEL% GEQ 1 PAUSE


ECHO.
ECHO. Slow Tests
ECHO. --------------------------------------------------------------------------------

Rscript "inst/slowTests/slowTest-results_get_csv_results_1549.R"
if %ERRORLEVEL% GEQ 1 PAUSE

ECHO.
ECHO.
ECHO.
ECHO.
ECHO.
ECHO.
ECHO.


ECHO. ================================================================================
PAUSE
