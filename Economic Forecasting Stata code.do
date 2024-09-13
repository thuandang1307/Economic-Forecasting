
* Ki thuat lap trinh Project final
 
 
*          Đặng Văn Thuận - 31211020299
 

import excel "/Users/thuan/Library/Mobile Documents/com~apple~CloudDocs/Sem5/KyThuatLapTrinh/CuoiKi/CPI/Vietnam_dataset_2002_2019.xlsx", sheet("Vietnam_dataset_2002_2019") firstrow clear
rename DATEM datestr
generate DATEM = monthly(datestr, "20YM")
format %tm DATEM
order DATEM, after(datestr)
tsset DATEM
tsline CPI, tlabel(, angle(forty_five)) ttitle("")
graph save panel1.gph, replace
tsline OILPRICE, tlabel(, angle(forty_five)) ttitle("")
graph save panel2.gph, replace
tsline RATE3M, tlabel(, angle(forty_five)) ttitle("") ytitle("3-month Interest rate, %")
graph save panel3.gph, replace
tsline VNDUSD, tlabel(, angle(forty_five)) ttitle("") ytitle("Exchange Rate VND/USD, x1000đ")
graph save panel4.gph, replace
graph combine panel1.gph panel2.gph panel3.gph panel4.gph, row(2)
label variable DATEM "Time"
gen lcpi = log(CPI)
gen dlcpi = d.lcpi*12*100
gen dvndusd = d.VNDUSD
tsline dlcpi
graph save panel5.gph, replace
tsline dvndusd
graph save panel6.gph, replace
graph combine panel5.gph panel6.gph

* Uniroot tests
dfuller lcpi 
pperron lcpi
dfuller VNDUSD
pperron VNDUSD

dfuller dlcpi
pperron dlcpi

dfuller dvndusd
pperron dvndusd

* test for VAR specification
varsoc dlcpi dvndusd 

*Johansen test for cointegration
vecrank dlcpi dvndusd, lag(1)

* Estimate VAR model
var dlcpi dvndusd, lag(1)

* VAR post-estimation
vargranger
varstable

* Lagrange Multiplier test
predict error, resid
summarize error
varlmar

* IRF analyst

irf set IRF
irf create IRF, step(12)
irf graph irf, irf(IRF) impulse(dlcpi dvndusd) response(dlcpi dvndusd)
irf table fevd, irf(IRF) impulse(dlcpi dvndusd) response(dlcpi) noci
irf table fevd, irf(IRF) impulse(dlcpi dvndusd) response(dvndusd) noci

* Forecasting
var dlcpi dvndusd, lag(1)
estimates store VARmod1

capture drop dlcpi_f dvndusd_f 

forecast create, replace
forecast estimates VARmod1
forecast solve, suffix(_f) begin(tm(2019m7)) end(tm(2019m12)) sim(betas, stat(stddev, suffix(_se)))
capture drop dlcpi_se dlcpi_fu dlcpi_fl
gen dlcpi_fu = dlcpi_f + 1.68*dlcpi_se 
gen dlcpi_fl = dlcpi_f - 1.68*dlcpi_se 

capture drop dnvdusd dvndusd dvndusd
gen dvndusd_fu = dvndusd_f + 1.68*dvndusd_se 
gen dvndusd_fl = dvndusd_f - 1.68*dvndusd_se 

* Plot
twoway (rarea dlcpi_fu dlcpi_fl DATEM if tin(2019m1, 2019m12), sort fcolor(gs8%50) lcolor(gs8%50) lwidth(none)) (tsline dlcpi dlcpi_f if tin(2019m1, 2019m12)), legend(cols(3))

twoway (rarea dvndusd_fu dvndusd_fl DATEM if tin(2019m1, 2019m12), sort fcolor(gs8%50) lcolor(gs8%50) lwidth(none)) (tsline dvndusd dvndusd_f if tin(2019m1, 2019m12)), legend(cols(3))

* Compute Forecasting Evaluation for "dlcpi" and "dvndusd" variable
capture drop mse_f_d
capture drop mae_f_d
qui: gen mse_f_d = (dlcpi_f - dlcpi)^2 if tin(2019m7, 2019m12)
qui: gen mae_f_d = abs(dlcpi_f - dlcpi) if tin(2019m7, 2019m12)
qui: summarize mse_f_d
display "rmse =" sqrt(r(mean))
qui: summarize mae_f_d
display "mae =" r(mean)

capture drop mse_f_dvndusd
capture drop mae_f_dvndusd
qui: gen mse_f_dvndusd = (dvndusd_f - dvndusd)^2 if tin(2019m7, 2019m12)
qui: gen mae_f_dvndusd = abs(dvndusd_f - dvndusd) if tin(2019m7, 2019m12)
qui: summarize mse_f_dvndusd
display "rmse =" sqrt(r(mean))
qui: summarize mae_f_dvndusd
display "mae =" r(mean)



