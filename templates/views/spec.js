define(['backbone', 'views/<%= router %>/<%= view.capitalize() %>View'], function(Backbone, <%= view.capitalize() %>View) {
    describe('<%= router.capitalize() %> <%= view.capitalize() %>View', function() {
        it('should handle the truth', function() {
            expect(true).toBeTruthy();
        });

        it('should exist', function() {
            expect(<%= view.capitalize() %>View).toBeTruthy();
        });

        it('should instantiate', function() {
            var x = new <%= view.capitalize() %>View({
                model: new Backbone.Model()
            });
            expect(x instanceof <%= view.capitalize() %>View).toBeTruthy();
            expect(x instanceof Backbone.View).toBeTruthy();
        });

        it('should have a render method', function() {
            var x = new <%= view.capitalize() %>View({
                model: new Backbone.Model()
            });
            x.render();
        });

        it('should render some text', function() {
             var x = new <%= view.capitalize() %>View({
                model: new Backbone.Model()
             });
            x.render();
            expect(x.el.html()).toMatch('<%= view.capitalize() %> Template!');
        });
    });
});

