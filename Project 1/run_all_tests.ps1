# Compile + run every ALU testbench with Icarus Verilog.
# Usage:  powershell -ExecutionPolicy Bypass -File run_all_tests.ps1
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

if (-not (Get-Command iverilog -ErrorAction SilentlyContinue)) {
    Write-Host "iverilog not found. Install from https://bleyer.org/icarus/ and re-run." -ForegroundColor Yellow
    exit 1
}

$rtl = @(
    "ALU.v","and8.v","or8.v","xor8.v","adder_8bit.v","subtractor_8bit.v",
    "array_multiplier_8bit.v","array_divider_8bit.v","div_stage_restoring.v",
    "barrel_shifter_left.v","barrel_shifter_right.v","decoder_4to9.v",
    "result_mux.v","flag_gen.v","full_adder.v","half_adder.v","mux2to1.v"
)

# name -> (rtl deps for that unit, testbench file)
$suites = [ordered]@{
    "ALU (master)"  = @($rtl + "ALU_tb.v")
    "adder_8bit"    = @("adder_8bit.v","full_adder.v","half_adder.v","adder_8bit_tb.v")
    "subtractor_8bit" = @("subtractor_8bit.v","full_adder.v","half_adder.v","subtractor_8bit_tb.v")
    "array_multiplier_8bit" = @("array_multiplier_8bit.v","adder_8bit.v","full_adder.v","half_adder.v","array_multiplier_8bit_tb.v")
    "array_divider_8bit" = @("array_divider_8bit.v","div_stage_restoring.v","full_adder.v","half_adder.v","mux2to1.v","array_divider_8bit_tb.v")
    "barrel_shifter_left" = @("barrel_shifter_left.v","mux2to1.v","barrel_shifter_left_tb.v")
    "barrel_shifter_right" = @("barrel_shifter_right.v","mux2to1.v","barrel_shifter_right_tb.v")
    "decoder_4to9"  = @("decoder_4to9.v","decoder_4to9_tb.v")
}

$fail = 0
foreach ($name in $suites.Keys) {
    Write-Host "=== $name ===" -ForegroundColor Cyan
    $files = $suites[$name]
    iverilog -g2012 -o _sim.out @files
    if ($LASTEXITCODE -ne 0) { Write-Host "COMPILE FAILED" -ForegroundColor Red; $fail++; continue }
    $out = vvp _sim.out
    $out | Write-Host
    if ($out -match "FAIL" -or $out -match "FAILURES") { $fail++ }
}
Remove-Item _sim.out -ErrorAction SilentlyContinue
Write-Host "==================================================" -ForegroundColor Cyan
if ($fail -eq 0) { Write-Host "ALL SUITES PASSED" -ForegroundColor Green }
else { Write-Host "$fail SUITE(S) HAD FAILURES" -ForegroundColor Red }
