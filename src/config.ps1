@{
    Arguments = @{
        "H"       = @{
            ParameterName = "Headers"
            Type          = "Hashtable"
            Value         = {
                $split = ($args[0].Split(':') -replace '\\"', '"')
                @{
                    ($split[0].Trim()) = (($split[1..$($split.count)] -join ':').Trim())
                }
            }
        }
        "header"  = "H"
        "X"       = @{
            ParameterName = "Method"
            Type          = "String"
            Value         = {
                $args[0].Trim()
            }
        }
        "request" = "X"
        "d"       = @{
            ParameterName = "Body"
            Type          = "String"
            Value         = {
                $_.Trim() -replace '\\"', '"'
            }
        }
        "data"    = "d"
        "url"     = @{
            ParameterName = "Uri"
            Type          = "String"
            Value         = {
                $_.Trim()
            }
        }
    }
}