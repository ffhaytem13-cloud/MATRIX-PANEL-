-- main.lua - MATRIX PANEL v1.0
-- المشروع الرئيسي
-- آخر تحديث: 2026

print("═══════════════════════════════")
print("🔷 MATRIX PANEL v1.0")
print("🔷 جاري التحميل...")
print("═══════════════════════════════")

-- تحميل الواجهة
local success, result = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ffhaytem13-cloud/MATRIX-PANEL-/main/gui.lua"))()
end)

if not success then
    warn("❌ خطأ: " .. tostring(result))
else
    print("✅ تم تحميل الواجهة")
end

print("✅ MATRIX PANEL جاهز!")
print("💡 اضغط M لفتح القائمة")
