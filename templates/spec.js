// baseUrl has been set to ../app so that module paths work properly
// specs should be referenced here as though you were in `app`
//     app/
//     spec/
require([
    '../spec/views/ApplicationViewSpec'
],
function() {
    jasmine.getEnv().addReporter(new jasmine.TrivialReporter());
    jasmine.getEnv().execute();
});
