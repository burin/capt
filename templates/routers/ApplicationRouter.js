define(['backbone', 'views/ApplicationView'], function(Backbone, ApplicationView) {
    var ApplicationRouter = Backbone.Router.extend({
        initialize: function() {
            this.viewport = new ApplicationView();
        },
        routes: {
            "" : "main",
            "other" : "other"
        },
        main: function() {
            this.viewport.render();
        },
        other: function() {
            this.viewport.render();
        }
    });

    return ApplicationRouter;
});
