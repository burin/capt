// register as a module with AMD.
define(['backbone'],function(Backbone) {
    var <%= model.capitalize() %> = Backbone.Model.extend({
        initialize: function() {
            //
        }
    });
    return <%= model.capitalize() %>;
});
