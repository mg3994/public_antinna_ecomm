# =========================================================================
# 1. SETUP & REUSABLE .NET ENGINE (Windows PowerShell 5.1 Compatible)
# =========================================================================
$Url = "https://script.google.com/macros/s/AKfycbyca4Xz_AE6Om1okIMf0TQ9EE9uIifQcVZhsDwnZK0K4weG7VD0w3jEzM0aCcuBeoWIIA/exec"

function Send-GasRequest {
    param (
        [string]$TargetUrl,
        [string]$JsonBody
    )
    try {
        # Fire the initial POST request with auto-redirect turned OFF
        $request = [System.Net.HttpWebRequest]::Create($TargetUrl)
        $request.Method = "POST"
        $request.ContentType = "application/json"
        $request.AllowAutoRedirect = $false
        
        # Write the JSON payload to the initial request stream
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($JsonBody)
        $request.ContentLength = $bytes.Length
        $reqStream = $request.GetRequestStream()
        $reqStream.Write($bytes, 0, $bytes.Length)
        $reqStream.Close()
        
        # Get the initial redirect response
        $response = $request.GetResponse()
        $statusCode = [int]$response.StatusCode
        
        # Catch the 302 Redirect
        if ($statusCode -eq 302 -or $statusCode -eq 301) {
            $redirectUrl = $response.Headers["Location"]
            $response.Close()
            
            # Fetch the pre-computed response via GET
            $redirectRequest = [System.Net.HttpWebRequest]::Create($redirectUrl)
            $redirectRequest.Method = "GET" 
            $redirectRequest.AllowAutoRedirect = $true 
            
            # Read the final execution output
            $redirectResponse = $redirectRequest.GetResponse()
            $reader = New-Object System.IO.StreamReader($redirectResponse.GetResponseStream())
            $responseText = $reader.ReadToEnd()
            $reader.Close()
            $redirectResponse.Close()
            
            return $responseText | ConvertFrom-Json
        } else {
            # Fallback if Google skips the redirect phase
            $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
            $responseText = $reader.ReadToEnd()
            $reader.Close()
            $response.Close()
            return $responseText | ConvertFrom-Json
        }
    } catch {
        Write-Host "❌ Request Failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.InnerException) {
            Write-Host "Details: $($_.Exception.InnerException.Message)" -ForegroundColor Yellow
        }
        return $null
    }
}

# =========================================================================
# TEST SCENARIO 1: Place Suggestions (getPlaceSuggestions)
# =========================================================================
Write-Host "`n--- Testing Action: getPlaceSuggestions ---" -ForegroundColor Cyan

$Payload1 = @{
    action = "getPlaceSuggestions"
    params = @{
        inputToken = "Rohtak Haryana"
    }
} | ConvertTo-Json -Depth 5

$Result1 = Send-GasRequest -TargetUrl $Url -JsonBody $Payload1
if ($Result1) { $Result1 | Format-List }

# =========================================================================
# TEST SCENARIO 2: Location and Routing Metrics (processLocationAndMetrics)
# =========================================================================
Write-Host "`n--- Testing Action: processLocationAndMetrics ---" -ForegroundColor Cyan

$Payload2 = @{
    action = "processLocationAndMetrics"
    params = @{
        originLat = 28.8955
        originLng = 76.6066
        destinationQuery = "Delhi Airport, India"
    }
} | ConvertTo-Json -Depth 5

$Result2 = Send-GasRequest -TargetUrl $Url -JsonBody $Payload2
if ($Result2) { $Result2 | Format-List }

# =========================================================================
# TEST SCENARIO 3: Pin Drop Metrics (processPinDropMetrics)
# =========================================================================
Write-Host "`n--- Testing Action: processPinDropMetrics ---" -ForegroundColor Cyan

$Payload3 = @{
    action = "processPinDropMetrics"
    params = @{
        originLat = 28.8955
        originLng = 76.6066
        pinLat    = 28.5561
        pinLng    = 77.0999
    }
} | ConvertTo-Json -Depth 5

$Result3 = Send-GasRequest -TargetUrl $Url -JsonBody $Payload3
if ($Result3) { $Result3 | Format-List }

# =========================================================================
# HALT TERMINAL FROM CLOSING
# =========================================================================
Write-Host "`n All tests completed successfully!" -ForegroundColor Green
Read-Host "Press Enter to exit and close this window"