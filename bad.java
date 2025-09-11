import org.apache.commons.collections.Transformer;
import org.apache.commons.collections.functors.ChainedTransformer;
import org.apache.commons.collections.functors.InvokerTransformer;
import org.apache.commons.collections.map.TransformedMap;

import java.util.HashMap;
import java.util.Map;

public class VulnerableCommonsApp {

    public static void main(String[] args) throws Exception {
        // Vulnerability: Using Apache Commons Collections 3.x with unsafe transformers
        Transformer[] transformers = new Transformer[] {
                new InvokerTransformer("toString", new Class[0], new Object[0])
        };

        Transformer transformerChain = new ChainedTransformer(transformers);

        Map<String, String> originalMap = new HashMap<>();
        originalMap.put("key", "value");

        // TransformedMap can be exploited during deserialization
        Map transformedMap = TransformedMap.decorate(originalMap, null, transformerChain);

        System.out.println("Transformed map: " + transformedMap);
    }
}
