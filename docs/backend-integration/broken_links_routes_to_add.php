<?php

// Add this to your existing routes/api.php file

use App\Http\Controllers\BrokenLinksController;

// Broken Links Routes
Route::middleware(['auth:sanctum'])->group(function () {
    // Report broken social media links
    Route::post('/broken-links/report', [BrokenLinksController::class, 'reportBrokenLinks']);
});

// Alternative: If you want to add it to the existing profile routes group
// Add this inside your existing profile middleware group:
/*
Route::middleware(['auth:sanctum'])->prefix('profile')->group(function () {
    // ... existing profile routes ...
    
    // Report broken social media links
    Route::post('/broken-links/report', [BrokenLinksController::class, 'reportBrokenLinks']);
});
*/
