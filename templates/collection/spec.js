define(['backbone', 'collections/<%= model.capitalize() %>Collection', 'models/<%= model.capitalize() %>'], function(Backbone, <%= model.capitalize() %>Collection, <%= model.capitalize() %>) {
    describe('<%= model.capitalize() %>Collection', function() {
        it('should handle the truth', function() {
            expect(true).toBeTruthy();
        });

        it('should exist', function() {
            expect(<%= model.capitalize() %>Collection).toBeTruthy();
        });

        it('should instantiate', function() {
            var x = new <%= model.capitalize() %>Collection();
            expect(x instanceof <%= model.capitalize() %>Collection).toBeTruthy();
            expect(x instanceof Backbone.Collection).toBeTruthy();
            expect(x.model === <%= model.capitalize() %>).toBeTruthy()
        });
    });
});


