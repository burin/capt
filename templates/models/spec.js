define(['backbone', 'models/<%= model.capitalize() %>'], function(Backbone, <%= model.capitalize() %>View) {
    describe('<%= model %> model', function() {
        it('should handle the truth', function() {
            expect(true).toBeTruthy();
        });

        it('should exist', function() {
            expect(<%= model.capitalize() %>).toBeTruthy();
        });

        it('should instantiate', function() {
            var x = new <%= model.capitalize() %>();
            expect(x instanceof <%= model.capitalize() %>).toBeTruthy();
            expect(x instanceof Backbone.Model).toBeTruthy();
        });
    });
});

