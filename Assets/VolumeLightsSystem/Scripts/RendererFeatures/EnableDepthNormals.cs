namespace UnityEngine.Rendering.Universal
{
    [DisallowMultipleRendererFeature]
    [Tooltip("Forces the DepthNormals prepass to be generated and available to shaders for both forward and deferred renderers.")]
    internal class EnableDepthNormals : ScriptableRendererFeature
    {
        // Private Fields
        private EnableDepthNormalsPass m_SSAOPass = null;

        /// <inheritdoc/>
        public override void Create()
        {
            // Create the pass...
            if (m_SSAOPass == null)
            {
                m_SSAOPass = new EnableDepthNormalsPass();
            }
        }

        /// <inheritdoc/>
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            bool shouldAdd = m_SSAOPass.Setup(renderer);
            if (shouldAdd)
            {
                renderer.EnqueuePass(m_SSAOPass);
            }
        }

        // The SSAO Pass
        private class EnableDepthNormalsPass : ScriptableRenderPass
        {
            internal bool Setup(ScriptableRenderer renderer)
            {
                ConfigureInput(ScriptableRenderPassInput.Normal);

                return true;
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                // Do Nothing - we only need the DepthNormals to be configured in the Setup method
            }
        }
    }
}