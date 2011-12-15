define(['backbone', 'hbs!templates/<%= controller %>/<%= view.capitalize() %>Template'], function(Backbone, template) {
    var <%= view.capitalize() %>View = Backbone.View.extend({
        initialize: function() {
            this.model.bind('change', this.render, this);
        },
        render: function() {
            this.el.innerHTML = this.template(this.model.toJSON());
        },
        template: template
    });
    return <%= view.capitalize() %>View;
});

