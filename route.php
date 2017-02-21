Route::get('/testdb', function () {
return Config::get('database.connections.'.Config::get('database.default').'.database');
});