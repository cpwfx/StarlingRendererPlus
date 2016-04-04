package starling.extensions.deferredShading.lights
{
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;

    import starling.display.DisplayObject;
    import starling.extensions.deferredShading.RenderPass;
    import starling.extensions.deferredShading.display.RendererPlus;
    import starling.extensions.deferredShading.lights.rendering.PointLightEffect;
    import starling.extensions.deferredShading.lights.rendering.PointLightStyle;
    import starling.extensions.deferredShading.renderer_internal;
    import starling.rendering.IndexData;
    import starling.rendering.Painter;
    import starling.rendering.VertexData;

    use namespace renderer_internal;

    /**
     * Omnidirectional light.
     */
    public class PointLight extends Light
    {
        private static var _helperMatrix:Matrix = new Matrix();
        private var _bounds:Rectangle = new Rectangle();
        private var _mNumEdges:int = 8;

        public function PointLight()
        {
            var vertexData:VertexData = new VertexData(PointLightEffect.VERTEX_FORMAT);
            var indexData:IndexData = new IndexData(24);
            var style:PointLightStyle = new PointLightStyle();

            super(vertexData, indexData, style);
            style.light = this;
            setupVertices();
        }

        override public function render(painter:Painter):void
        {
            if(RendererPlus.renderPass == RenderPass.LIGHTS)
            {
                var style:PointLightStyle = this.style as PointLightStyle;

                style.center.setTo(0, 0);
                localToGlobal(style.center, style.center);
                super.render(painter);
            }
        }

        public function setupVertices():void
        {
            this.vertexData.clear();
            this.indexData.clear();

            var i:int;
            var vertexData:VertexData = this.vertexData;
            var indexData:IndexData = this.indexData;

            //            indexData.numIndices = mNumEdges * 3;
            //            vertexData.numVertices = mNumEdges + 1;

            for(i = 0; i < _mNumEdges; ++i)
            {
                var edge:Point = Point.polar((style as PointLightStyle).excircleRadius, (i * 2 * Math.PI) / _mNumEdges + 22.5 * Math.PI / 180);
                vertexData.setPoint(i, 'position', edge.x, edge.y);
            }

            // Center vertex
            vertexData.setPoint(_mNumEdges, 'position', 0.0, 0.0);

            // Fill index data for triangles

            for(i = 0; i < _mNumEdges; ++i)
                indexData.addTriangle(_mNumEdges, i, (i + 1) % _mNumEdges);

            setRequiresRedraw();
        }

        /** @inheritDoc */
        public override function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle
        {
            if(out == null) out = new Rectangle();

            var transformationMatrix:Matrix = targetSpace == this ?
                    null : getTransformationMatrix(targetSpace, _helperMatrix);

            return vertexData.getBounds('position', transformationMatrix, 0, -1, out);
        }

        /** @inheritDoc */
        override public function hitTest(localPoint:Point):DisplayObject
        {
            if(!visible || !touchable || !hitTestMask(localPoint)) return null;
            else if(_bounds.containsPoint(localPoint)) return this;
            else return null;
        }

        // Does nothing, this light is a circle after all

        private var _rotation:Number;

        override public function get rotation():Number
        {
            return _rotation;
        }

        override public function set rotation(value:Number):void
        {
            _rotation = value;
        }
    }
}