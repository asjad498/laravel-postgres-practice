<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('/health', function (){
    try {
        // Try to connect to the database
        DB::connection()->getPdo();
        
        return response()->json([
            'status' => 'OK',
            'database' => 'Connected',
            'database_name' => DB::getDatabaseName(),
            'driver' => config('database.default'),
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'ERROR',
            'database' => 'Not Connected',
            'message' => $e->getMessage(),
        ], 500);
    }
});


Route::get('/db/tables', function () {
    try {
        // Get all tables from the 'public' schema
        $tables = DB::select("
            SELECT tablename 
            FROM pg_tables 
            WHERE schemaname = 'public'
        ");

        $tableNames = collect($tables)->pluck('tablename');

        return response()->json([
            'status' => 'success',
            'schema' => 'public',
            'tables' => $tableNames,
            'count' => $tableNames->count(),
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage(),
        ], 500);
    }
});
