// register as a module with AMD, bring in Model as dependency
define(['backbone', 'models/<%= model.capitalize() %>'], function (Backbone, <%= model.capitalize() %>) {
    var <%= model.capitalize() %>Collection = Backbone.Collection.extend({
        model: <%= model.capitalize() %>
    });
    return <%= model.capitalize() %>Collection;
});

