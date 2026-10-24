$files = Get-ChildItem -Path "d:\Lab211\DangKyXeVaBamBienProject\Project\web" -Filter "*.jsp" -Recurse
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $content = $content.Replace('uri="jakarta.tags.core"', 'uri="http://java.sun.com/jsp/jstl/core"')
    $content = $content.Replace('uri="jakarta.tags.fmt"', 'uri="http://java.sun.com/jsp/jstl/fmt"')
    [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
    Write-Output "Updated $($file.Name)"
}
