define(['backbone', 'hbs!templates/<%= router %>/<%= view.capitalize() %>Template'], function(Backbone, template) {
    var <%= view.capitalize() %>View = Backbone.View.extend({
        initialize: function() {
            this.el = $(this.el);
            this.model.bind('change', this.render, this);
        },
        render: function() {
            this.el.html(this.template(this.model.toJSON()));
        },
        template: template
    });
    return <%= view.capitalize() %>View;
});

