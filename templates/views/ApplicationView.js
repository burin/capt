define(['backbone'], function(Backbone) {
    var ApplicationView = Backbone.View.extend({
        initialize: function() {
        },
        el: $('#app'),
        render: function() {
            this.el.append('<section>well hello there!</section>');
        }
    });

    return ApplicationView;
});
