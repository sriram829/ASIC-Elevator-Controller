#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Thu Dec 11 04:33:46 2025                
#                                                     
#######################################################

#@(#)CDS: Innovus v20.14-s095_1 (64bit) 04/19/2021 14:41 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: NanoRoute 20.14-s095_1 NR210411-1939/20_14-UB (database version 18.20.547) {superthreading v2.13}
#@(#)CDS: AAE 20.14-s018 (64bit) 04/19/2021 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: CTE 20.14-s027_1 () Apr 13 2021 21:29:07 ( )
#@(#)CDS: SYNTECH 20.14-s017_1 () Mar 25 2021 13:07:27 ( )
#@(#)CDS: CPE v20.14-s080
#@(#)CDS: IQuantus/TQuantus 20.1.1-s460 (64bit) Fri Mar 5 18:46:16 PST 2021 (Linux 2.6.32-431.11.2.el6.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getVersion
win
set ::TimeLib::tsgMarkCellLatchConstructFlag 1
set init_lef_file {
    /home/install/FOUNDRY/digital/90nm/dig/lef/gsclib090_translated.lef
    /home/install/FOUNDRY/digital/90nm/dig/lef/gsclib090_translated_ref.lef
}
set init_pwr_net VDD
set init_gnd_net VSS
set init_mmmc_file Default.view
set init_verilog elevator_netlist.v
set defHierChar /
set init_design_settop 0
set pegDefaultResScaleFactor 1.0
set pegDetailResScaleFactor 1.0
init_design
set ::TimeLib::tsgMarkCellLatchConstructFlag 1
set conf_qxconf_file NULL
set conf_qxlib_file NULL
set defHierChar /
set init_design_settop 1
set init_gnd_net VSS
set init_pwr_net VDD
set init_lef_file { 
    /home/install/FOUNDRY/digital/90nm/dig/lef/gsclib090_translated.lef
}
set init_mmmc_file Default.view
set init_verilog { elevator_netlist.v }
set init_top_cell elevator_controller
set pegDefaultResScaleFactor 1.0
set pegDetailResScaleFactor 1.0
init_design
zoomBox -1.02500 3.51250 39.86500 40.11800
zoomBox 1.11750 8.16250 35.87400 39.27700
zoomBox 2.93850 12.11450 32.48150 38.56200
zoomBox -1.02600 3.51200 39.86500 40.11800
zoomBox -3.54650 -1.95850 44.56050 41.10750
