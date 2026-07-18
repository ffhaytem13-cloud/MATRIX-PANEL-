-- main.lua - MATRIX PANEL v1.0
-- الملف الرئيسي - يحمل gui.lua و functions.lua

print("🔷 MATRIX PANEL v1.0")
print("🔷 جاري التحميل...")

local success1, result1 = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ffhaytem13-cloud/MATRIX-PANEL-/main/functions.lua"))()
end)

local success2, result2 = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ffhaytem13-cloud/MATRIX-PANEL-/main/gui.lua"))()
end)

if success1 and success2 then
    print("✅ MATRIX PANEL جاهز!")
    print("💡 اضغط M لفتح القائمة")
else
    print("❌ خطأ في التحميل")
end
